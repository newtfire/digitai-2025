import os
import logging
import time
from sentence_transformers import SentenceTransformer
from tqdm import tqdm

# Limit CPU threads to avoid overheating / crashing
os.environ["OMP_NUM_THREADS"] = "4"
os.environ["MKL_NUM_THREADS"] = "4"

# Set up logging
logging.basicConfig(
    filename="embedding.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

logging.info("Starting embedding script...")

# Load model
try:
    logging.info("Loading BGE-M3 model...")
    model = SentenceTransformer("BAAI/bge-m3")
except Exception as e:
    logging.error(f"Failed to load model: {e}")
    raise SystemExit(f"[FATAL] Could not load model: {e}")

# Replace this with your own node data loading logic
# Example: nodes = [{"id": "001", "text": "example sentence"}, ...]
nodes = [...]  # ← load your actual list here

BATCH_SIZE = 32
embeddings = []

for i in tqdm(range(0, len(nodes), BATCH_SIZE), desc="Embedding nodes"):
    batch = nodes[i:i + BATCH_SIZE]
    texts = [n["text"] for n in batch]
    ids = [n["id"] for n in batch]

    try:
        batch_embeddings = model.encode(
            texts,
            batch_size=BATCH_SIZE,
            convert_to_tensor=False,
            show_progress_bar=False,
            normalize_embeddings=True
        )
    except Exception as e:
        logging.error(f"Failed to embed batch {i}–{i + BATCH_SIZE}: {e}")
        continue

    for node_id, emb in zip(ids, batch_embeddings):
        embeddings.append({
            "id": node_id,
            "embedding": emb
        })

    logging.info(f"Embedded batch {i}–{i + BATCH_SIZE}")
    time.sleep(0.1)  # throttle CPU slightly

logging.info(f"Embedding complete. Total nodes embedded: {len(embeddings)}")

# Save or return embeddings
# Example:
# with open("bge_embeddings.json", "w") as f:
#     json.dump(embeddings, f)