import os
import json
import faiss
import numpy as np
import logging
from digitaiCore.config_loader import ConfigLoader

# === Load Config ===
repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
config_path = os.path.join(repo_root, "digitaiCore", "config.yaml")
config = ConfigLoader(config_path)

# === Logging Setup ===
log_path = os.path.join(repo_root, config.get("logging.faissLog"))
os.makedirs(os.path.dirname(log_path), exist_ok=True)

logging.basicConfig(
    filename=log_path,
    level=getattr(logging, config.get("logging.level")),
    format=config.get("logging.format")
)

logging.info("=== FAISS Index Build Script Start ===")

# === Paths ===
embedding_path = os.path.join(repo_root, config.get("dataPaths.bgem3Embeddings"))
index_output_path = os.path.join(repo_root, config.get("dataPaths.faissIndex"))
id_map_path = os.path.join(repo_root, config.get("dataPaths.faissIdMap"))

os.makedirs(os.path.dirname(index_output_path), exist_ok=True)
os.makedirs(os.path.dirname(id_map_path), exist_ok=True)

dimension = config.get("vectorIndex.dimension")

# === Load Embeddings ===
logging.info(f"📥 Loading embeddings from: {embedding_path}")
embeddings = []
id_map = []

with open(embedding_path, "r", encoding="utf-8") as f:
    for i, line in enumerate(f):
        line = line.strip()
        if not line:
            continue
        record = json.loads(line)
        embeddings.append(record["embedding"])
        id_map.append(record["id"])  # FAISS index position → node_id

embedding_matrix = np.array(embeddings, dtype="float32")

if embedding_matrix.size == 0:
    raise ValueError("No embeddings loaded — check your embeddings JSONL path/content.")

# === Normalize if configured ===
if config.get("embedding.normalize"):
    logging.info("📐 Normalizing embeddings for cosine similarity...")
    faiss.normalize_L2(embedding_matrix)

# === Dimension handling ===
try:
    dimension = int(dimension) if dimension is not None else None
except Exception:
    dimension = None

if dimension is None or (embedding_matrix.ndim == 2 and embedding_matrix.shape[1] != dimension):
    actual_dim = embedding_matrix.shape[1] if embedding_matrix.ndim == 2 else 0
    if dimension not in (None, actual_dim):
        logging.warning(f"Configured dimension ({dimension}) != data dimension ({actual_dim}); using {actual_dim}.")
    dimension = actual_dim

# === Build FAISS Index ===
logging.info(f"🔧 Building FAISS index: {len(embedding_matrix)} vectors, dimension = {dimension}")
index = faiss.IndexFlatIP(dimension)
index.add(embedding_matrix)

# === Save Index and ID Map ===
faiss.write_index(index, index_output_path)
logging.info(f"✅ FAISS index saved to: {index_output_path}")

with open(id_map_path, "w", encoding="utf-8") as f:
    json.dump(id_map, f)
logging.info(f"🗂️  ID map saved to: {id_map_path}")
logging.info("🏁 FAISS Index Build Script Complete.")