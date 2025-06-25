import os
import subprocess
from digitaiCore.utils.configLoader import ConfigLoader
# No XML Libraries needed, parsing and extraction are done inside XSLT stylesheet

"""
This class is responsible for handling the batch execution of XSLT transformations
on a corpus of TEI XML files, producing JSON outputs using using xsltproc.
"""
class XsltRunner:
    """
    Initialize XsltRunner with dynamic paths loaded from config
    """
    def __init__(self, config: ConfigLoader, corpusName: str):
        self.inputPath = os.path.join(config.get('dataPaths.xmlRoot'), corpusName) # Input: Raw TEI XML files
        self.xsltPath = config.get('xsltPaths.teiExtraction')  # XSLT Stylesheet to apply (Same for all files)
        self.outputPath = os.path.join(config.get('dataPaths.extractedRoot'), corpusName) # Output Directory

    """
    Apply the XSLT transformation to every XML file in the corpus
    **Output files will be JSON formatted**
    """
    def run(self):
        # Make sure output directory exists (create if it doesn't)
        os.makedirs(self.outputPath, exist_ok=True)

        # Iterate over all files in the input folder
        for filename in os.listdir(self.inputPath):
            # Skip non-XML files
            if not filename.endswith('.xml'):
                continue

            # Build full paths for input and output files
            inputFile = os.path.join(self.inputPath, filename)
            baseName = os.path.splitext(filename)[0]
            outputFile = os.path.join(self.outputPath, f"{baseName}.json") # Change extension of output to .json

            cmd = [
                "xsltproc",
                "-o", outputFile,
                self.xsltPath,
                inputFile
            ]

            try:
                subprocess.run(cmd, check=True)
                print(f"Processed: {fileName} → {baseName}.json")
            except subprocess.CalledProcessError as e:
                print(f"Error processing {filename}: {e}")
