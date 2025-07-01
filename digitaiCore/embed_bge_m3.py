import os
import json
import time
import torch
import logging
from sentence_transformers import SentenceTransformer
from digitaiCore.config_loader import ConfigLoader
from neo4j import GraphDatabase

# Load config
repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
config_path = os.path.join(repo_root, "digitai", "digitaiCore", "config.yaml")
config = ConfigLoader(config_path)

# Set torch thread limits
torch.set_num_threads(config.get("performance.num_threads"))
torch.set_num_interop_threads(config.get("performance.interop_threads"))
os.environ["TOKENIZERS_PARALLELISM"] = str(config.get("performance.tokenizers_parallelism")).lower()

# Setup logging
if config.get("logging.enabled"):
    logging.basicConfig(
        filename=config.get("logging.file"),
        level=getattr(logging, config.get("logging.level")),
        format=config.get("logging.format")
    )
    logging.info("=== Embedding Script Start ===")

# Load model
model_name = config.get("embedding.model")
try:
    model = SentenceTransformer(model_name)
    if config.get("logging.enabled"):
        logging.info(f"Loaded model: {model_name}")
except Exception as e:
    logging.exception("Model load failed")
    raise SystemExit(f"[FATAL] Could not load model: {e}")

# Setup Neo4j driver
driver = GraphDatabase.driver(
    config.get("neo4j.uri"),
    auth=(config.get("neo4j.user"), config.get("neo4j.password"))
)

# Fetch data from Neo4j
def fetch_nodes(tx):
    cypher_query = config.get("neo4j.cypher")
    result = tx.run(cypher_query)
    return [(record["node_id"], record["text"]) for record in result if record["node_id"] and record["text"]]

with driver.session() as session:
    try:
        nodes = session.execute_read(fetch_nodes)
        if config.get("logging.enabled"):
            logging.info(f"Fetched {len(nodes)} nodes from Neo4j")
    except Exception as e:
        logging.exception("Error fetching nodes from Neo4j")
        raise

driver.close()

if not nodes:
    raise ValueError("No nodes fetched from Neo4j. Check your query and database state.")

# Embed in batches
batch_size = config.get("embedding.batch_size")
normalize = config.get("embedding.normalize")
throttle = config.get("embedding.throttle")

output_dir = os.path.join(repo_root, "data", "p5")
os.makedirs(output_dir, exist_ok=True)
print(f"[DEBUG] Writing to: {os.path.join(output_dir, config.get('dataPaths.outputFile'))}")
output_file = os.path.join(output_dir, config.get("dataPaths.outputFile"))

with open(output_file, "w") as f:
    for i in range(0, len(nodes), batch_size):
        batch = nodes[i:i + batch_size]
        ids, texts = zip(*batch)
        try:
            batch_embeddings = model.encode(
                list(texts),
                batch_size=batch_size,
                convert_to_numpy=True,
                normalize_embeddings=normalize,
                show_progress_bar=True
            )
            for node_id, emb in zip(ids, batch_embeddings):
                record = {"id": node_id, "embedding": emb.tolist()}
                f.write(json.dumps(record) + "\n")
            if config.get("logging.enabled"):
                logging.info(f"Successfully embedded batch {i} to {i + len(batch)}")
        except Exception as e:
            if config.get("logging.enabled"):
                logging.error(f"Embedding failed for batch {i} to {i + len(batch)}: {e}")
            continue

        time.sleep(throttle)

if config.get("logging.enabled"):
    logging.info(f"Saved embeddings to {output_file}")
    logging.info("=== Embedding Script End ===")
