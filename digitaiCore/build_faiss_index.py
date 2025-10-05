import os
import json
import faiss
import numpy as np
import logging
from digitaiCore.config_loader import ConfigLoader

repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..")) #Set path of root
config_path = os.path.join(repo_root, "digitaiCore", "config.yaml") #Set path of config.yaml
config = ConfigLoader(config_path) #Load in config

log_path = os.path.join(repo_root, config.get("logging.faissLog"))

os.makedirs(os.path.dirname(log_path), exist_ok=True)

logging.basicConfig(
    filename=log_path,
    level=getattr(logging, config.get("logging.level")),
    format=config.get("logging.format")
)

logging.info("=== FAISS Index Build Script Start ===")

embedding_path = os.path.join(repo_root, config.get("dataPaths.bgem3Embeddings"))
index_output_path = os.path.join(repo_root, config.get("dataPaths.faissIndex"))
id_map_path = os.path.join(repo_root, config.get("dataPaths.faissIdMap"))
dimension = config.get("vectorIndex.dimension")

logging.info(f"📥 Loading embeddings from: {embedding_path}")
embeddings = []
id_map = {}

with open(embedding_path, "r") as f:
    for i, line in enumerate(f):
        record = json.loads(line)
        embeddings.append(record["embedding"])
        id_map[i] = record["id"]  # FAISS index position → node_id

embedding_matrix = np.array(embeddings).astype("float32")

if config.get("embedding.normalize"):
    logging.info("📐 Normalizing embeddings for cosine similarity...")
    embedding_matrix = faiss.normalize_L2(embedding_matrix)

logging.info(f"🔧 Building FAISS index: {len(embedding_matrix)} vectors, dimension = {dimension}")
index = faiss.IndexFlatIP(dimension)
index.add(embedding_matrix)

faiss.write_index(index, index_output_path)
logging.info(f"✅ FAISS index saved to: {index_output_path}")

# Save ID map
with open(id_map_path, "w") as f:
    json.dump(id_map, f)
logging.info(f"🗂️  ID map saved to: {id_map_path}")
logging.info("🏁 FAISS Index Build Script Complete.")