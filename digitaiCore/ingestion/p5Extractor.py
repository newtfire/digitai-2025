import os
import subprocess
from digitaiCore.utils.configLoader import ConfigLoader

def transform_p5(): #Apply XSLT to full P5
    #Load Config
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

    # Build xsltproc command
    xsltRun = [
        "xsltproc", # Call the xslt processor
        "-o", output, # Assign output
        stylesheet, # Path to xslt
        input # input file being transformed
    ]

    try:
        subprocess.run(xsltRun, check=True)
        print(f"Successfully transformed {input} -> {output}")
    except subprocess.CalledProcessError as e:
        print(f"XSLT processing failed: {e}")

# Make executable in other files
if __name__ == "__main__":
    transform_p5()