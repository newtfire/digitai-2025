import os
import json
from neo4j import GraphDatabase
from digitaiCore.config_loader import ConfigLoader

"""
--- Load configuration ---
"""
repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
config_path = os.path.join(repo_root, "digitaiCore", "config.yaml")
config = ConfigLoader(config_path)

# Load config values
output_path = os.path.join(repo_root, config.get("dataPaths.neo4jExport"))
neo4j_uri = config.get("neo4j.uri")
neo4j_user = config.get("neo4j.user")
neo4j_password = config.get("neo4j.password")
cypher_query = config.get("cypher.export_all")  # Uses full export query from nested config

"""
--- Export node data from Neo4j to JSONL ---
"""
def export_neo4j_to_jsonl(uri, user, password, query, output_file):
    driver = GraphDatabase.driver(uri, auth=(user, password))

    with driver.session() as session:
        result = session.run(query)
        count = 0

        with open(output_file, "w", encoding="utf-8") as f:
            for record in result:
                json.dump({
                    "id": record["node_id"],
                    "text": record.get("text", ""),
                    "labels": record.get("labels", [])
                }, f)
                f.write("\n")
                count += 1

        print(f"✅ Exported {count} nodes to {output_file}")

    driver.close()

"""
--- Run export ---
"""
if __name__ == "__main__":
    export_neo4j_to_jsonl(
        uri=neo4j_uri,
        user=neo4j_user,
        password=neo4j_password,
        query=cypher_query,
        output_file=output_path
    )