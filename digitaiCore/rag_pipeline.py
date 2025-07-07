import os
import json
import numpy as np # Handles embeddings as numeric arrays
import faiss # Facebook library for fast nearest-neighbor search
import requests # Used to send http requests to local Ollama server
from neo4j import GraphDatabase # Lets python talk to neo4j
from sklearn.preprocessing import normalize as sk_normalize # Translates embeddings from angles to magnitudes to be read by FAISS
from sentence_transformers import SentenceTransformer # Used for generating user query and loading model
from digitaiCore.config_loader import ConfigLoader # Loads presets from config.yaml

"""
--- Load config ---
"""
repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
config_path = os.path.join(repo_root, "digitaiCore", "config.yaml")
config = ConfigLoader(config_path)

"""
--- Config values ---
"""
embedding_file = os.path.join(repo_root, config.get("dataPaths.outputFile"))
embedding_dim = config.get("vectorIndex.dimension")
neo4j_uri = config.get("neo4j.uri")
neo4j_user = config.get("neo4j.user")
neo4j_password = config.get("neo4j.password")
embedding_model = config.get("embedding.model")
normalize = config.get("embedding.normalize")
llm_model = config.get("llm.model")

"""
--- Load Embeddings ---
"""
print("🔄 Loading embeddings from", embedding_file) # Show embedding source directory
embeddings = [] # Stores embedding vectors
id_map = [] # Holds node ID's used to query Neo4j

with open(embedding_file, "r") as f: # Open Json file
    for line in f:
        item = json.loads(line) # Parse lines
        embeddings.append(item["embedding"]) # Collects numeric vectors
        id_map.append(item["id"]) # Collects ID's used to map FAISS index results back to neo4j

embeddings = np.array(embeddings).astype("float32") # Converts list of lists to NumPy matrix in 32-bit floating format (Required by FAISS)

# Apply L2 normalization only if normalize: true in config (cosine similarity support)
if normalize:
    embeddings = sk_normalize(embeddings, norm='l2')

"""
--- Build FAISS Index ---
FAISS (Facebook AI Similarity Search) is used to efficiently find the most similar vectors (embeddings) to a given query.

We're using an IndexFlatIP:
  - "Flat": keeps all vectors in memory, no approximation
  - "IP": uses inner product (dot product) as the similarity metric

If vectors are L2 normalized, inner product is equivalent to cosine similarity.
This is often used for semantic similarity tasks like RAG.

Example:
  Given a query vector q, FAISS will search for vectors v in the index such that q ⋅ v is maximized.
"""
print("⚡ Building FAISS index...")
index = faiss.IndexFlatIP(embedding_dim)  # Create a flat inner-product index
index.add(embeddings)  # Add all our pre-computed document embeddings into the index

"""
--- Load SentenceTransformer (embedding) Model ---
"""
print(f"🧠 Loading model: {embedding_model}")
model = SentenceTransformer(embedding_model)

"""
# --- Get Query from User ---
# Request input from user and than send that input to embedding model for conversion to a 1024-dimensional embedding
"""
query = input("❓ Enter your query: ")
query_embedding = model.encode(query)

"""
 --- Normalize and Format Query Vector ---
# Convert 1D query vector (1024,) to 2D (1, 1024) for FAISS compatibility

# Example
# a = np.array([1, 2, 3])
# print(a.shape)  # (3,) → one-dimensional array of length 3
# 
# b = np.array([[1, 2, 3]])
# print(b.shape)  # (1, 3) → two-dimensional array: 1 row, 3 columns
"""




if normalize: # If normalize True
    # Wrap vector in list to make it a 2D array and apply L2 normalization (Scales vector so that length (magnitude)=1)
    # This makes dot product=cosine
    query_embedding = sk_normalize([query_embedding], norm='l2')

else: # If normalize False
    # Wrap the query in a 2D vector array but DO NOT scale it (retains origional magnitude)
    query_embedding = np.array([query_embedding])

query_embedding = query_embedding.astype("float32") # Convert vector to 32-bit floating precision (FAISS required)

"""
# --- Perform FAISS Search and Fetch Matching Texts ---
"""
TOP_K = 5  # Number of most similar embeddings to retrieve from FAISS

scores, indices = index.search(query_embedding, TOP_K)

# Check if all returned indices are -1 (i.e., no valid matches found at all)
# Example: if only 3 matches exist and you ask for 5, FAISS may return something like [[3, 7, 12, -1, -1]]
if all(i == -1 for i in indices[0]):
    print("⚠️ No valid matches found in FAISS index.")
    exit()

matched_ids = [id_map[i] for i in indices[0] if i != -1]  # Map FAISS result indices back to Neo4j element IDs

texts = fetch_node_texts_by_ids(matched_ids)  # Retrieve corresponding node texts from Neo4j

if not texts:  # If no matching texts were found in the graph
    print("❌ No texts found in Neo4j for the retrieved IDs.")
    exit()

"""
--- Build Prompt from Retrieved Texts---
"""

context = "\n".join(f"- {text}" for text in texts) # Joins all the TOP_K embeddings together as bullet style list

# Primer prompt to initialize the model
prompt = f"""You are a chatbot that helps people understand the TEI guidelines which specify how to encode machine-readable texts using XML.

Context:
{context}

Question:
{query}
"""

"""
--- Call Local Ollama ---
"""
# --- Function to send a prompt to the locally running Ollama server ---
def ask_ollama(prompt, model):
    try:
        # Sends a POST request to Ollama's HTTP API at localhost:11434
        # Endpoint: /api/generate — used to generate completions from a local model
        # Payload includes:
        #   - model: Name of the model to use (e.g., "qwen:7b")
        #   - prompt: The full prompt constructed earlier (context + user question)
        #   - stream: False → disables streaming, so we get a full response at once
        response = requests.post(
            "http://localhost:11434/api/generate",
            json={
                "model": model,
                "prompt": prompt,
                "stream": False
            }
        )

        # Parse the JSON response and return only the 'response' field (the LLM's generated answer)
        return response.json()["response"]

    except Exception as e:
        # Catches connection failures, invalid responses, or any other issues with the API call
        print("❌ Error calling Ollama:", e)
        return "[ERROR] Could not get response from local LLM."

# --- Status message before asking the model ---
print(f"🤖 Asking local LLM ({llm_model}) via Ollama...")

# Call the function with the generated prompt and model name
answer = ask_ollama(prompt, llm_model)

# --- Display the result from the model in a clean format ---
print("\n🧾 Response:\n")
print(answer)