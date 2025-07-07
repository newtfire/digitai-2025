import os
import json
import numpy as np  # Handles embeddings as numeric arrays
import faiss  # Facebook library for fast nearest-neighbor search
import requests  # Used to send HTTP requests to local Ollama server
from sklearn.preprocessing import normalize as sk_normalize  # Applies L2 normalization to match cosine similarity
from sentence_transformers import SentenceTransformer  # Used for generating user query and loading model
from digitaiCore.config_loader import ConfigLoader  # Loads presets from config.yaml

"""
This script performs Retrieval-Augmented Generation (RAG) by:
- Loading precomputed text embeddings from a JSONL file
- Using FAISS to perform similarity search on these embeddings
- Retrieving the corresponding node texts from the node export JSONL
- Generating an answer using a locally running Ollama LLM

Neo4j is not required during this step because both node data and embeddings
have already been exported using `neo4j_exporter.py` and `embed_bge_m3.py`.
"""

# === Load config values ===
repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
config_path = os.path.join(repo_root, "digitaiCore", "config.yaml")
config = ConfigLoader(config_path)

embedding_file = os.path.join(repo_root, config.get("dataPaths.outputFile"))  # Contains id + embedding
node_file = os.path.join(repo_root, config.get("dataPaths.outputFile"))       # Same file also contains id + text + labels
embedding_dim = config.get("vectorIndex.dimension")
embedding_model = config.get("embedding.model")
normalize = config.get("embedding.normalize")
llm_model = config.get("llm.model")

"""
--- Load Embeddings ---
"""
print("🔄 Loading embeddings from", embedding_file)
embeddings = []  # Stores embedding vectors
id_map = []      # Maps FAISS results back to node IDs

with open(embedding_file, "r") as f:
    for line in f:
        item = json.loads(line)
        if "embedding" in item:  # Skip rows without embeddings
            embeddings.append(item["embedding"])
            id_map.append(item["id"])

embeddings = np.array(embeddings).astype("float32")  # FAISS requires float32 matrix

# Normalize if cosine similarity is required
if normalize:
    embeddings = sk_normalize(embeddings, norm='l2')

"""
--- Build FAISS Index ---
FAISS (Facebook AI Similarity Search) is used to efficiently find the most similar vectors (embeddings) to a given query.

We're using IndexFlatIP:
- "Flat": brute-force index, all vectors are stored
- "IP": Inner Product, used as similarity metric (equivalent to cosine when vectors are L2-normalized)
"""
print("⚡ Building FAISS index...")
index = faiss.IndexFlatIP(embedding_dim)
index.add(embeddings)

"""
--- Load Embedding Model for Query ---
"""
print(f"🧠 Loading embedding model: {embedding_model}")
model = SentenceTransformer(embedding_model)

"""
--- Get Query from User and Convert to Embedding ---
"""
query = input("❓ Enter your query: ")
query_embedding = model.encode(query)

# Convert query vector from 1D → 2D for FAISS, normalize if enabled
if normalize:
    query_embedding = sk_normalize([query_embedding], norm='l2')
else:
    query_embedding = np.array([query_embedding])
query_embedding = query_embedding.astype("float32")

"""
--- Perform FAISS Search ---
"""
TOP_K = 5  # Number of most similar embeddings to retrieve

scores, indices = index.search(query_embedding, TOP_K)

if all(i == -1 for i in indices[0]):
    print("⚠️ No valid matches found in FAISS index.")
    exit()

matched_ids = [id_map[i] for i in indices[0] if i != -1]

"""
--- Fetch Node Texts by IDs from JSONL File ---
"""
def fetch_node_texts_by_ids(node_ids):
    node_texts = []
    with open(node_file, "r", encoding="utf-8") as f:
        for line in f:
            record = json.loads(line)
            if record.get("id") in node_ids and record.get("text"):
                node_texts.append(record["text"])
    return node_texts

texts = fetch_node_texts_by_ids(matched_ids)

if not texts:
    print("❌ No texts found in the local JSONL node file for the matched IDs.")
    exit()

"""
--- Build Prompt from Retrieved Texts ---
"""
context = "\n".join(f"- {text}" for text in texts)  # Formats as a bullet list

# Construct full prompt
prompt = f"""You are a chatbot that helps people understand the TEI guidelines which specify how to encode machine-readable texts using XML.

Context:
{context}

Question:
{query}
"""

"""
--- Send Prompt to Local Ollama Server ---
"""
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
        return response.json()["response"]
    except Exception as e:
        print("❌ Error calling Ollama:", e)
        return "[ERROR] Could not get response from local LLM."

print(f"🤖 Asking local LLM ({llm_model}) via Ollama...")
answer = ask_ollama(prompt, llm_model)

"""
--- Display Final Output ---
"""
print("\n🧾 Response:\n")
print(answer)