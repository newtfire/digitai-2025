import json
from neo4j import GraphDatabase
from sentence_transformers import SentenceTransformer
from tqdm import tqdm
import os

# === Config ===
NEO4J_URI = "bolt://localhost:7687"
NEO4J_USER = "neo4j"
NEO4J_PASSWORD = "d1g1tai!"
OUTPUT_PATH = "data/embeddings.jsonl"
EMBEDDING_MODEL = "BAAI/bge-m3"

# === Connect to Neo4j ===
driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))

# === Load Embedding Model ===
model = SentenceTransformer(EMBEDDING_MODEL)

# === Build Context String for Each Node ===
def build_context(tx):
    query = """
    MATCH (n)
    OPTIONAL MATCH (n)-[r]->(m)
    OPTIONAL MATCH (m2)-[r2]->(n)
    RETURN n, collect(DISTINCT [type(r), m]) + collect(DISTINCT [type(r2), m2]) AS rels
    """
    results = tx.run(query)
    output = []

    for record in results:
        node = record["n"]
        rels = record["rels"]

        node_id = node.id
        labels = list(node.labels)
        props = dict(node)

        # 1. Base description
        prop_str = ", ".join(f"{k}: {v}" for k, v in props.items())
        context = f"{' / '.join(labels)}: {prop_str}"

        # 2. Add relationship context
        for rel in rels:
            if rel and len(rel) == 2 and rel[1] is not None:
                rel_type = rel[0]
                other = rel[1]
                other_label = list(other.labels)
                other_props = dict(other)
                summary = other_props.get("name") or other_props.get("title") or str(other_props)
                context += f" | {rel_type} → {summary} ({' / '.join(other_label)})"

        output.append({
            "node_id": node_id,
            "labels": labels,
            "text": context
        })
    return output

# === Run Query and Build Contexts ===
with driver.session() as session:
    print("Querying Neo4j and building context strings...")
    node_data = session.execute_read(build_context)

# === Generate Embeddings ===
print("Generating embeddings with BGE-M3...")
with open(OUTPUT_PATH, "w") as f:
    for item in tqdm(node_data):
        embedding = model.encode(item["text"], normalize_embeddings=True).tolist()
        f.write(json.dumps({
            "node_id": item["node_id"],
            "labels": item["labels"],
            "text": item["text"],
            "embedding": embedding
        }) + "\n")

print(f"\n✅ Embeddings saved to: {OUTPUT_PATH}")