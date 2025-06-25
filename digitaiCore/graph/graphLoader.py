import os
import subprocess
import shutil
from digitaiCore.utils.configLoader import Configloader

def load_graph(): # Loads P5 JSON into neo4j using Hadleighs prewritten Cypher
    config = Configloader("digitaiCore/config.yaml")

    extracted = config.get("dataPaths.p5Extracted")
    neo4jExport = config.get("dataPaths.p5GraphExport")
    localOutput = config.get("dataPaths.p5GraphLocal")
    cypherScript = config.get("neo4j.p5Cypher")
    neo4jUri = config.get("neo4j.uri")
    neo4jUser = config.get("neo4j.user")
    neo4jPass = config.get("neo4j.pass")


    # Confirm extracted JSON Exists
    if not os.path.exists(extracted):
        print(f"Extracted JSON not found at {extracted}")
        return

    if not os.path.exists(cypherScript):
        print(f"Cypher script not found at {cypherScript}")
        return

    print(f"JSON file found at {extracted}")
    print(f"Running Cypher script: {cypherScript} via Cypher-Shell")

    try:
        subprocess.run([
            "cypher-shell",
            "-a", neo4jUri,
            "-u", neo4jUser,
            "-p", neo4jPass,
            "-f", cypherScript
        ], check=True)
        print("Cypher script executed successfully.")

        # Confirm export and copy to local output
        if os.path.exists(neo4jExport):
            os.makedirs(os.path.dirname(localOutput), exist_ok=True)
            shutil.copy(neo4jExport, localOutput)
            print(f"✅ Graph export copied to: {localOutput}")
        else:
            print(f"⚠️  Exported JSON not found at: {neo4jExport}")
            print("→ Confirm APOC export path and Neo4j export config.")

    except subprocess.CalledProcessError as e:
        print(f"Cypher-shell failed: {e}")

if __name__ == "__main__":
    load_graph()