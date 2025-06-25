import os
import subprocess
from digitaiCore.utils.configLoader import ConfigLoader

# Make sure to brew install Saxon — this allows running XSLT
def transform_p5():  # Apply XSLT to full P5
    # Load Config
    config = ConfigLoader("digitaiCore/config.yaml")

    # Set path variables from config
    input = config.get("dataPaths.p5Root")
    output = config.get("dataPaths.p5Extracted")
    stylesheet = config.get("xsltPaths.teiExtraction")

    # Make sure output directory exists
    os.makedirs(os.path.dirname(output), exist_ok=True)

    # Delete old output if it exists
    if os.path.exists(output):
        os.remove(output)

    # Build Saxon CLI command
    saxonRun = [
        "saxon",  # Saxon CLI (installed via brew or available in PATH)
        "-s:" + input,  # -s: input file
        "-xsl:" + stylesheet,  # -xsl: path to the XSLT file
        "-o:" + output  # -o: output JSON file
    ]

    try:
        subprocess.run(saxonRun, check=True)
        print(f"Successfully transformed: {input} → {output}")
    except FileNotFoundError:
        print("Saxon not found. Make sure it's installed and on your PATH.")
    except subprocess.CalledProcessError as e:
        print(f"XSLT transformation failed: {e}")

# Make executable in other files
if __name__ == "__main__":
    transform_p5()