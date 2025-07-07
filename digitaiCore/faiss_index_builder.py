import os
import json
import numpy as np  # For numeric arrays and vector math
import faiss  # Facebook AI Similarity Search - fast vector lookup
import requests  # For making HTTP requests to the local LLM
import logging  # For runtime logging and debugging
from sklearn.preprocessing import normalize as sk_normalize  # For cosine similarity normalization
from sentence_transformers import SentenceTransformer  # Model used to embed user query
from digitaiCore.config_loader import ConfigLoader  # Loads YAML config with dot-notation access

"""
This script performs a full Retrieval-Augmented Generation (RAG) cycle:
1. Loads a FAISS index + ID map generated from previous embedding steps.
2. Embeds a user query using the same SentenceTransformer model as the node data.
3. Searches the FAISS index for the most similar embedded nodes.
4. Pulls the original node text from the exported Neo4j JSONL file.
5. Constructs a context + question prompt and sends it to a local Ollama LLM.
6. Prints the response and logs each stage of the process for debugging.

This pipeline assumes all prior stages (export → embed → index) are complete.
"""

# === Load configuration from repo root ===
repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
config_path = os.path.join(repo_root, "digitaiCore", "config.yaml")
config = ConfigLoader(config_path)

# === Setup logging if enabled ===
if config.get("logging.enabled"):
    log_path = os.path.join(repo_root, config.get("logging.ragLog"))
    os.makedirs(os.path.dirname(log_path), exist_ok=True)
    logging.basicConfig(
        filename=log_path,
        level=getattr(logging, config.get("logging.level")),
        format=config.get("logging.format")
    )
    logging.info("=== RAG Pipeline Started ===")

# === Resolve file paths from config ===
node_file = os.path.join(repo_root, config.get("dataPaths.neo4jExport"))  # Raw node data from Neo4j
index_path = os.path.join(repo_root, config.get("dataPaths.faissIndex"))  # FAISS index path
id_map_path = os.path.join(repo_root, config.get("dataPaths.faissIdMap"))  # Map from FAISS position to node ID

# === Embedding model parameters ===
embedding_model = config.get("embedding.model")  # Must match what was used for node vectors
embedding_dim = config.get("vectorIndex.dimension")  # Dimensionality of embeddings (e.g., 1024)
normalize = config.get("embedding.normalize")  # Whether cosine normalization is used

# === LLM parameters ===
llm_model = config.get("llm.model")  # Name of the local Ollama model to send prompt to

# === Load FAISS index from disk ===
try:
    print(f"📅 Loading FAISS index from: {index_path}")
    index = faiss.read_index(index_path)
    logging.info(f"Loaded FAISS index from {index_path}")
except Exception as e:
    logging.exception("Failed to load FAISS index")
    raise SystemExit("[FATAL] Failed to load FAISS index")

# === Load FAISS ID map from disk ===
try:
    print(f"📅 Loading ID map from: {id_map_path}")
    with open(id_map_path, "r") as f:
        id_map = json.load(f)
    logging.info(f"Loaded ID map from {id_map_path}")
except Exception as e:
    logging.exception("Failed to load ID map")
    raise SystemExit("[FATAL] Failed to load FAISS ID map")

# === Load the query embedding model ===
try:
    print(f"🧐 Loading embedding model: {embedding_model}")
    model = SentenceTransformer(embedding_model)
    logging.info(f"Loaded embedding model: {embedding_model}")
except Exception as e:
    logging.exception("Failed to load embedding model")
    raise SystemExit("[FATAL] Failed to load embedding model")

# === Get user input from terminal ===
query = input("❓ Enter your query: ").strip()
if not query:
    print("⚠️ No query provided. Exiting.")
    logging.warning("No query entered by user. Exiting.")
    exit()

# === Encode the user query to match embedding space ===
query_embedding = model.encode(query)
if normalize:
    query_embedding = sk_normalize([query_embedding], norm='l2')
else:
    query_embedding = np.array([query_embedding])
query_embedding = query_embedding.astype("float32")

# === Perform vector similarity search ===
TOP_K = 5  # How many nodes to retrieve from index
scores, indices = index.search(query_embedding, TOP_K)
matched_ids = [id_map[i] for i in indices[0] if i != -1]

if not matched_ids:
    print("⚠️ No relevant matches found in the FAISS index.")
    logging.warning("No matches found in FAISS index for query.")
    exit()
logging.info(f"Top {len(matched_ids)} match IDs: {matched_ids}")

# === Pull matching text records from Neo4j-exported JSONL file ===
def fetch_node_texts_by_ids(node_ids):
    texts = []
    with open(node_file, "r", encoding="utf-8") as f:
        for line in f:
            record = json.loads(line)
            if record.get("id") in node_ids and record.get("text"):
                texts.append(record["text"])
    return texts

texts = fetch_node_texts_by_ids(matched_ids)
if not texts:
    print("❌ No node texts found for matched IDs.")
    logging.error("Matched IDs found but no corresponding node texts.")
    exit()

# === Construct the prompt sent to the LLM ===
context = "\n".join(f"- {text}" for text in texts)
prompt = f"""You are a chatbot that helps people understand the TEI guidelines which specify how to encode machine-readable texts using XML.

Context:
{context}

Question:
{query}
"""

# === Send prompt to the Ollama LLM endpoint ===
def ask_ollama(prompt, model):
    try:
        response = requests.post(
            "http://localhost:11434/api/generate",
            json={
                "model": model,
                "prompt": prompt,
                "stream": False
            }
        )
        return response.json().get("response", "[ERROR] Empty response from LLM.")
    except Exception as e:
        logging.exception("Ollama query failed")
        return "[ERROR] Could not get response from local LLM."

# === Generate and display answer ===
print(f"🤖 Sending prompt to LLM ({llm_model})...")
answer = ask_ollama(prompt, llm_model)

print("\n📜 Response:\n")
print(answer)

# === Log pipeline success ===
if config.get("logging.enabled"):
    logging.info("RAG pipeline completed successfully.")
