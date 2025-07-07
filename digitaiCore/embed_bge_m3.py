import os
import json
import time
import torch
import logging
from sentence_transformers import SentenceTransformer
from digitaiCore.config_loader import ConfigLoader
from neo4j import GraphDatabase

"""
This script loads a text embedding model, fetches text data from a Neo4j graph database,
computes embeddings for the text in batches, and saves these embeddings to a file.
It uses configurations from an external YAML file to control behavior such as model choice,
batch size, logging, and database connection details.
"""

# Load configuration settings from an external YAML file.
# These settings include parameters for performance, logging, embedding, and database access.
repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
config_path = os.path.join(repo_root, "digitaiCore", "config.yaml")
config = ConfigLoader(config_path)

# Set the number of threads used by PyTorch for parallel CPU operations.
# This can help optimize performance depending on the hardware.
torch.set_num_threads(config.get("performance.num_threads"))
# Set the number of threads used for inter-op parallelism in PyTorch.
torch.set_num_interop_threads(config.get("performance.interop_threads"))
# Control parallelism in tokenizers library to avoid excessive CPU usage.
os.environ["TOKENIZERS_PARALLELISM"] = str(config.get("performance.tokenizers_parallelism")).lower()

# Setup logging to record events, errors, and progress.
# This is useful for debugging and tracking the script's execution.
if config.get("logging.enabled"):
    logging.basicConfig(
        filename=config.get("logging.file"),
        level=getattr(logging, config.get("logging.level")),
        format=config.get("logging.format")
    )
    logging.info("=== Embedding Script Start ===")

# Load the SentenceTransformer model specified in the config.
# Logging here helps confirm successful model loading or capture errors.
model_name = config.get("embedding.model")
try:
    model = SentenceTransformer(model_name)
    if config.get("logging.enabled"):
        logging.info(f"Loaded model: {model_name}")
except Exception as e:
    # Log the exception details to help diagnose why the model failed to load.
    logging.exception("Model load failed")
    raise SystemExit(f"[FATAL] Could not load model: {e}")

# Setup Neo4j driver for connecting to the graph database.
# This driver allows running Cypher queries to fetch nodes and their text.
driver = GraphDatabase.driver(
    config.get("neo4j.uri"),
    auth=(config.get("neo4j.user"), config.get("neo4j.password"))
)

# Function to fetch nodes from Neo4j using a Cypher query.
# The query retrieves node IDs and associated text for embedding.
def fetch_nodes(tx):
    cypher_query = config.get("neo4j.cypher")
    # Run the Cypher query and extract node_id and text from each record.
    result = tx.run(cypher_query)
    return [(record["node_id"], record["text"]) for record in result if record["node_id"] and record["text"]]

# Open a session with the Neo4j driver to execute the fetch_nodes function.
# If fetching fails, log the error and raise an exception.
with driver.session() as session:
    try:
        nodes = session.execute_read(fetch_nodes)
        if config.get("logging.enabled"):
            logging.info(f"Fetched {len(nodes)} nodes from Neo4j")
    except Exception as e:
        logging.exception("Error fetching nodes from Neo4j")
        raise

driver.close()

# Check if any nodes were fetched. If none, this is a critical failure
# because there is no data to embed, so the script cannot continue.
if not nodes:
    raise ValueError("No nodes fetched from Neo4j. Check your query and database state.")

# Retrieve embedding parameters from config.
batch_size = config.get("embedding.batch_size")  # Number of texts to embed in one batch
normalize = config.get("embedding.normalize")    # Whether to normalize embeddings
throttle = config.get("embedding.throttle")      # Seconds to wait between batches

# Resolve the full output file path relative to the repo root.
relative_output_path = config.get("dataPaths.outputFile")
output_file = os.path.join(repo_root, relative_output_path)

# Ensure the directory for the output file exists.
os.makedirs(os.path.dirname(output_file), exist_ok=True)

print(f"[DEBUG] Writing to: {output_file}")

# Loop over the nodes in batches, embed their texts, and write embeddings to file.
with open(output_file, "w") as f:
    for i in range(0, len(nodes), batch_size):
        batch = nodes[i:i + batch_size]
        ids, texts = zip(*batch)
        try:
            # Encode the batch of texts using the model to get embeddings.
            # convert_to_numpy=True returns numpy arrays for easier handling.
            # normalize_embeddings applies normalization if specified.
            # show_progress_bar gives visual feedback during encoding.
            batch_embeddings = model.encode(
                list(texts),
                batch_size=batch_size,
                convert_to_numpy=True,
                normalize_embeddings=normalize,
                show_progress_bar=True
            )
            # Write each embedding as a JSON line with its corresponding node ID.
            for node_id, emb in zip(ids, batch_embeddings):
                embedding_entry = {"id": node_id, "embedding": emb.tolist()}
                f.write(json.dumps(embedding_entry) + "\n")
                f.flush()  # Flush to ensure data is written to disk promptly.
            if config.get("logging.enabled"):
                logging.info(f"Successfully embedded batch {i} to {i + len(batch)}")
        except Exception as e:
            # Log errors for this batch but continue processing subsequent batches.
            if config.get("logging.enabled"):
                logging.error(f"Embedding failed for batch {i} to {i + len(batch)}: {e}")
            continue

        # Sleep between batches to throttle resource usage as configured.
        time.sleep(throttle)

# Final logging indicating where embeddings have been saved and script completion.
if config.get("logging.enabled"):
    logging.info(f"Saved embeddings to {output_file}")
    logging.info("=== Embedding Script End ===")
