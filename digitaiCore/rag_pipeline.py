import os
import json
import numpy as np  # For numeric arrays and vector math
import faiss  # Facebook AI Similarity Search - fast vector lookup
import requests  # To send prompt to Ollama server
from sklearn.preprocessing import normalize as sk_normalize  # For cosine similarity
from sentence_transformers import SentenceTransformer  # Used to embed the user query
from digitaiCore.config_loader import ConfigLoader  # Loads config from YAML via dot notation
from datetime import datetime

"""
This script performs a single Retrieval-Augmented Generation (RAG) step by:

1. Loading a FAISS index and ID map generated from node embeddings
2. Embedding a user query using a SentenceTransformer model
3. Performing a vector similarity search using FAISS
4. Fetching corresponding node texts from a local JSONL file
5. Building a prompt and passing it to a locally running LLM via Ollama
6. Printing the generated response

Note:
- This script **does not use Neo4j live** — it works with pre-exported data.
- Embeddings and node data must already be generated using `neo4j_exporter.py` and `embed_bge_m3.py`.
- FAISS index must be built once with `build_faiss_index.py`.
"""

# === Load config ===
repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
config_path = os.path.join(repo_root, "digitaiCore", "config.yaml")
config = ConfigLoader(config_path)

# === Get key config values ===
neo4jNodes = os.path.join(repo_root, config.get("dataPaths.neo4jExport")) # File with node text + embeddings
index_path = os.path.join(repo_root, config.get("dataPaths.faissIndex")) # FAISS index file
id_map_path = os.path.join(repo_root, config.get("dataPaths.faissIdMap")) # JSON list mapping FAISS index → node ID
embedding_model = config.get("embedding.model") # SentenceTransformer model
embedding_dim = config.get("vectorIndex.dimension") # Must match FAISS dimensions
normalize = config.get("embedding.normalize") # Whether to normalize for cosine
llm_model = config.get("llm.model") # e.g. "qwen:7b"

# === Load FAISS index and ID map ===
print(f"📥 Loading FAISS index from: {index_path}")
index = faiss.read_index(index_path)

print(f"📥 Loading ID map from: {id_map_path}")
with open(id_map_path, "r") as f:
    id_map = json.load(f) # List of node IDs, indexed to match FAISS result indices

# === Load query embedding model ===
print(f"🧠 Loading embedding model: {embedding_model}")
model = SentenceTransformer(embedding_model)

# === Get user input ===
query = input("❓ Enter your query: ").strip()
if not query:
    print("⚠️ No query provided. Exiting.")
    exit()

# === Encode the query ===
query_embedding = model.encode(query)

# Convert to 2D array and normalize if cosine similarity is enabled
if normalize:
    query_embedding = sk_normalize([query_embedding], norm="l2")
else:
    query_embedding = np.array([query_embedding])
query_embedding = query_embedding.astype("float32")

# === Perform FAISS similarity search ===
TOP_K = 5 # Number of top matching texts to retrieve
scores, indices = index.search(query_embedding, TOP_K)

# Filter out invalid results (-1 = no match)
matched_ids = [id_map[i] for i in indices[0] if i != -1]
if not matched_ids:
    print("⚠️ No relevant matches found in the FAISS index.")
    exit()

# === Fetch matching texts from JSONL file ===
def fetch_node_texts_by_ids(node_ids):
    texts = []
    with open(neo4jNodes, "r", encoding="utf-8") as f:
        for line in f:
            record = json.loads(line)
            if record.get("id") in node_ids and record.get("text"):
                texts.append(record["text"])
    return texts

texts = fetch_node_texts_by_ids(matched_ids)

if not texts:
    print("❌ No node texts found for matched IDs in local file.")
    exit()

# === Construct prompt for the LLM ===
context = "\n".join(f"- {text}" for text in texts)
prompt = f"""You are a chatbot that helps people understand the TEI guidelines which specify how to encode machine-readable texts using XML.

Answer the question below in the **same language the question is asked in**.
Use examples from the provided context as needed — they can be in any language. Do not translate them.

Context:
{context}

Question:
{query}
"""

# === Send prompt to local Ollama LLM ===
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
        print("❌ Error while querying Ollama:", e)
        return "[ERROR] Could not get response from local LLM."

# === Query the model ===
print(f"🤖 Sending prompt to LLM ({llm_model})...")
answer = ask_ollama(prompt, llm_model)

# === Display the result ===
print("\n🧾 Response:\n")
print(answer)

log_file_path = os.path.join(repo_root, config.get("logging.conversationHistory"))
os.makedirs(os.path.dirname(log_file_path), exist_ok=True)
with open(log_file_path, "a", encoding="utf-8") as log_file:
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_file.write(f"[{timestamp}]\nQuestion: {query}\nAnswer: {answer}\n\n")

while True:
    follow_up = input("\n❓ Do you want to ask a follow-up question? (yes/no): ").strip().lower()
    if follow_up not in ("yes", "y"):
        print("👋 Exiting RAG pipeline.")
        break
    new_query = input("❓ Enter your follow-up query: ").strip()
    if not new_query:
        print("👋 Exiting RAG pipeline.")
        break
    # Rebuild prompt using previous answer as context
    prompt = f"""You are a chatbot that helps people understand the TEI guidelines which specify how to encode machine-readable texts using XML.

Answer the question below in the **same language the question is asked in**.
Use examples from the provided context as needed — they can be in any language. Do not translate them.

Context:
{answer}

Question:
{new_query}
"""
    print(f"🤖 Sending prompt to LLM ({llm_model})...")
    answer = ask_ollama(prompt, llm_model)
    print("\n🧾 Response:\n")
    print(answer)
    # Log the follow-up question and answer to the same log file
    with open(log_file_path, "a", encoding="utf-8") as log_file:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_file.write(f"[{timestamp}]\nQuestion: {new_query}\nAnswer: {answer}\n\n")