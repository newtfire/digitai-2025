import os
import json
import time
import torch
import logging
from sentence_transformers import SentenceTransformer
from digitaiCore.config_loader import ConfigLoader

# === Load Configuration ===
repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
config_path = os.path.join(repo_root, "digitaiCore", "config.yaml")
config = ConfigLoader(config_path)

# === Set Performance Parameters ===
# Controls the number of threads used by PyTorch and Hugging Face tokenizer internals.
# Proper configuration helps prevent CPU overcommitment or stalls during parallel batch encoding.
torch.set_num_threads(config.get("performance.num_threads"))
torch.set_num_interop_threads(config.get("performance.interop_threads"))
os.environ["TOKENIZERS_PARALLELISM"] = str(config.get("performance.tokenizers_parallelism")).lower()

# === Setup Logging ===
# Logging behavior is controlled via config.yaml and writes to a specified file in digitaiCore.
# This helps track batch-level progress and catch embedding failures during long runs.
if config.get("logging.enabled"):
    logging.basicConfig(
        filename=config.get("logging.file"),
        level=getattr(logging, config.get("logging.level")),
        format=config.get("logging.format")
    )
    logging.info("=== Embedding Script Start ===")

# === Load SentenceTransformer Model ===
# The embedding model specified in the config will be used to convert natural language into numerical vectors.
# Model names can include "BAAI/bge-m3", "all-MiniLM-L6-v2", etc., depending on your use case and system resources.
model_name = config.get("embedding.model")
try:
    model = SentenceTransformer(model_name)
    if config.get("logging.enabled"):
        logging.info(f"Loaded model: {model_name}")
except Exception as e:
    logging.exception("Model load failed")
    raise SystemExit(f"[FATAL] Could not load model: {e}")

# === Load Node Texts from JSONL File ===
# This replaces Neo4j queries by loading a static file created by neo4j_exporter.py.
# Each line in the file should be a JSON object with 'id', 'text', and optional 'labels'.
input_path = os.path.join(repo_root, config.get("dataPaths.outputFile"))
if not os.path.exists(input_path):
    raise SystemExit(f"[FATAL] Input file not found: {input_path}")

nodes = []
with open(input_path, "r", encoding="utf-8") as f:
    for line in f:
        record = json.loads(line)
        # Only embed nodes that contain actual body text; structure-only nodes are skipped
        if record.get("text"):
            nodes.append((record["id"], record["text"]))

if config.get("logging.enabled"):
    logging.info(f"Loaded {len(nodes)} nodes with text from {input_path}")

# === Fail Early if No Embeddable Nodes Exist ===
# This prevents wasting GPU/CPU resources or generating an empty output file.
if not nodes:
    if config.get("logging.enabled"):
        logging.error("No text nodes found in the input file. Cannot proceed.")
    raise SystemExit("[FATAL] No text nodes found in the input JSONL file. Check your export or path.")

# === Read Embedding Settings ===
# These are controlled through config.yaml and affect batching, normalization, and resource pacing.
batch_size = config.get("embedding.batch_size")     # Number of documents per batch
normalize = config.get("embedding.normalize")       # If True, performs L2 normalization (cosine similarity prep)
throttle = config.get("embedding.throttle")         # Optional pause between batches (in seconds)

# === Resolve Output File Path ===
# Embedding results are written to the same path as input, unless separated in config.
output_path = os.path.join(repo_root, config.get("dataPaths.outputFile"))
os.makedirs(os.path.dirname(output_path), exist_ok=True)
print(f"[DEBUG] Writing embeddings to: {output_path}")

# === Embed Texts in Batches ===
# For each batch of node texts, compute sentence embeddings and write each result to a new JSONL line.
with open(output_path, "w", encoding="utf-8") as f:
    for i in range(0, len(nodes), batch_size):
        batch = nodes[i:i + batch_size]
        ids, texts = zip(*batch)

        try:
            # Generate embeddings using the SentenceTransformer model.
            # Returns a NumPy array which we convert to lists for JSON serialization.
            batch_embeddings = model.encode(
                list(texts),
                batch_size=batch_size,
                convert_to_numpy=True,
                normalize_embeddings=normalize,
                show_progress_bar=True
            )

            # Write each node ID and its embedding to disk immediately to avoid memory buildup.
            for node_id, emb in zip(ids, batch_embeddings):
                json.dump({"id": node_id, "embedding": emb.tolist()}, f)
                f.write("\n")

            if config.get("logging.enabled"):
                logging.info(f"Embedded batch {i} to {i + len(batch)}")
        except Exception as e:
            # Catch errors without halting the script; logs the batch that failed.
            if config.get("logging.enabled"):
                logging.error(f"Embedding failed for batch {i} to {i + len(batch)}: {e}")
            continue

        # Optional throttle between batches to manage memory or shared system load.
        time.sleep(throttle)

# === Final Status ===
# Log the script completion and file path to confirm success in automated pipelines.
if config.get("logging.enabled"):
    logging.info(f"Saved embeddings to {output_path}")
    logging.info("=== Embedding Script End ===")