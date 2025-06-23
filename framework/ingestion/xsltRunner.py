import os #Performs file system operations
import subprocess #Runs external commands
#No XML Libraries needed, parsing and extraction are done inside XSLT stylesheet

class XsltRunner:
    def __init__(self, inputPath, xsltPath, outputPath):
        self.inputPath = '../data/xml/p5Subset'
        self.xsltPath = '../framework/ingestion/teiExtraction.xsl'
        self.outputPath = '../data/extractedData/p5Subset/'



