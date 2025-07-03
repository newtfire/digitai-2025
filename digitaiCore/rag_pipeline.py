import os
import json
import numpy as np
import faiss
import requests
from neo4j import GraphDatabase
from sklearn.preprocessing import normalize as sk_normalize
from sentence_transformers import SentenceTransformer
from digitaiCore.config_loader import ConfigLoader

# --- Load config ---
repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
config_path = os.path.join(repo_root, "digitaiCore", "config.yaml")
config = ConfigLoader(config_path)

# --- Config values ---
embedding_file = os.path.join(repo_root, config.get("dataPaths.outputFile"))
embedding_dim = config.get("vectorIndex.dimension")
neo4j_uri = config.get("neo4j.uri")
neo4j_user = config.get("neo4j.user")
neo4j_password = config.get("neo4j.password")
embedding_model = config.get("embedding.model")
normalize = config.get("embedding.normalize")
llm_model = config.get("llm.model") if config.get("llm.model") else "qwen:7b"

# --- Load Embeddings ---
print("🔄 Loading embeddings from", embedding_file)
embeddings = []
id_map = []

with open(embedding_file, "r") as f:
    for line in f:
        item = json.loads(line)
        embeddings.append(item["embedding"])
        id_map.append(item["id"])

embeddings = np.array(embeddings).astype("float32")
if normalize:
    embeddings = sk_normalize(embeddings, norm='l2')

# --- Build FAISS Index ---
print("⚡ Building FAISS index...")
index = faiss.IndexFlatIP(embedding_dim)
index.add(embeddings)

# --- Load SentenceTransformer Model ---
print(f"🧠 Loading model: {embedding_model}")
model = SentenceTransformer(embedding_model)

# --- Get Query from User ---
query = input("❓ Enter your query: ")
query_embedding = model.encode(query)
if normalize:
    query_embedding = sk_normalize([query_embedding], norm='l2')
else:
    query_embedding = np.array([query_embedding])
query_embedding = query_embedding.astype("float32")

# --- Search Top K ---
TOP_K = 5
scores, indices = index.search(query_embedding, TOP_K)
matched_ids = [id_map[i] for i in indices[0] if i != -1]

print("🧠 FAISS returned IDs:", matched_ids)

# --- Neo4j: Fetch Node Text by elementId(n) ---
driver = GraphDatabase.driver(neo4j_uri, auth=(neo4j_user, neo4j_password))

def fetch_node_texts_by_ids(node_ids):
    with driver.session() as session:
        print("🔎 Looking up those IDs in Neo4j...")
        result = session.run(
            "MATCH (n) WHERE elementId(n) IN $ids RETURN elementId(n) AS id, n.text AS text",
            ids=node_ids
        )
        records = [record for record in result]
        print(f"📥 Matched {len(records)} nodes in Neo4j.")
        return [r["text"] for r in records]

texts = fetch_node_texts_by_ids(matched_ids)
driver.close()

if not texts:
    print("❌ No texts found in Neo4j for the retrieved IDs.")
    exit()

# --- Build Prompt ---
context = "\n".join(f"- {text}" for text in texts)
prompt = f"""You are a chatbot that helps people understand the TEI guidelines which specify how to encode machine-readable texts using XML.

Context:
{context}

Question:
{query}
"""

# --- Call Local Ollama ---
def ask_ollama(prompt, model):
    try:
        response = requests.post(
            "http://localhost:11434/api/generate",
            json={"model": model, "prompt": prompt, "stream": False}
        )
        return response.json()["response"]
    except Exception as e:
        print("❌ Error calling Ollama:", e)
        return "[ERROR] Could not get response from local LLM."

print(f"🤖 Asking local LLM ({llm_model}) via Ollama...")
answer = ask_ollama(prompt, llm_model)

print("\n🧾 Response:\n")
print(answer)