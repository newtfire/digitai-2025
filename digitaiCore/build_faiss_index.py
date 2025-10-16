import os
import json
import faiss
import numpy as np
import logging
import psutil
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
logging.info(f"Config loaded from {config_path}")
logging.info(f"Repository root: {repo_root}")

# === Utility: Memory Snapshot ===
def log_memory(prefix=""):
    try:
        process = psutil.Process(os.getpid())
        mem = process.memory_info().rss / (1024 ** 2)
        logging.debug(f"[MEMORY] {prefix} {mem:.2f} MB in use")
    except Exception:
        pass  # psutil not critical

# === Paths ===
embedding_path = os.path.join(repo_root, config.get("dataPaths.bgem3Embeddings"))
index_output_path = os.path.join(repo_root, config.get("dataPaths.faissIndex"))
id_map_path = os.path.join(repo_root, config.get("dataPaths.faissIdMap"))

os.makedirs(os.path.dirname(index_output_path), exist_ok=True)
os.makedirs(os.path.dirname(id_map_path), exist_ok=True)

dimension = config.get("vectorIndex.dimension")

# === Load Embeddings ===
import time
start_time = time.time()
log_memory("Before loading embeddings:")

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
        if (i + 1) % 10000 == 0:
            logging.debug(f"Read {i + 1} lines from embeddings file so far...")

load_time = time.time() - start_time
logging.info(f"Loaded {len(embeddings)} embeddings in {load_time:.2f}s")
log_memory("After loading embeddings:")

embedding_matrix = np.array(embeddings, dtype="float32")

if embedding_matrix.size == 0:
    raise ValueError("No embeddings loaded — check your embeddings JSONL path/content.")

# === Normalize if configured ===
if config.get("embedding.normalize"):
    logging.info("📐 Normalizing embeddings for cosine similarity...")
    faiss.normalize_L2(embedding_matrix)
    log_memory("After normalization:")

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
index_start = time.time()
log_memory("Before building index:")

logging.info(f"🔧 Building FAISS index: {len(embedding_matrix)} vectors, dimension = {dimension}")
index = faiss.IndexFlatIP(dimension)
index.add(embedding_matrix)

build_time = time.time() - index_start
logging.info(f"Index built in {build_time:.2f}s")
log_memory("After building index:")

# === Save Index and ID Map ===
save_start = time.time()

faiss.write_index(index, index_output_path)
logging.info(f"✅ FAISS index saved to: {index_output_path}")

with open(id_map_path, "w", encoding="utf-8") as f:
    json.dump(id_map, f)
logging.info(f"🗂️  ID map saved to: {id_map_path}")

total_time = time.time() - start_time
save_time = time.time() - save_start
logging.info(f"Saved index and ID map in {save_time:.2f}s")
logging.info(f"Total FAISS build runtime: {total_time:.2f}s")
log_memory("Final snapshot:")
