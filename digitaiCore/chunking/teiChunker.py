import os
import json
from digitaiCore.utils.configLoader import ConfigLoader

"""
This class reads extracted JSON files and chunks them into logical units
based on TEI structure (paragraph-level chunking). Output is raw text.
"""
class TeiChunker:
    def __init__(self, config: ConfigLoader, corpusName: str):
        self.inputPath = os.path.join(config.get('dataPaths.extractedRoot'), corpusName)
        self.outputPath = os.path.join(config.get('dataPaths.chunkedRoot'), corpusName)

    """
    Process all extracted JSON files in the input folder and chunk them.
    """
    def processAllFiles(self):
        os.makedirs(self.outputPath, exist_ok=True)

        for fileName in os.listdir(self.inputPath):
            if not fileName.endswith('.json'):
                continue

            inputFile = os.path.join(self.inputPath, fileName)
            baseName = os.path.splitext(fileName)[0]

            with open(inputFile, 'r', encoding='utf-8') as f:
                data = json.load(f)

            chunkCount = self.chunkJson(data, baseName)
            print(f"{fileName}: {chunkCount} chunks created.")

    """
    Chunk a single JSON object based on TEI-like structure.
    Returns: number of chunks created.
    """
    def chunkJson(self, data, baseName):
        chunkCounter = 0
    #No clue how to chunk yet. Heres a example of how we could do it:
        # Write title as its own chunk
        if 'title' in data:
            chunkCounter += 1
            self.writeChunk(baseName, chunkCounter, f"Title: {data['title']}")

        # Write author as its own chunk
        if 'author' in data:
            chunkCounter += 1
            self.writeChunk(baseName, chunkCounter, f"Author: {data['author']}")

        # Process body paragraphs
        if 'body' in data:
            for section in data['body']:
                if 'paragraph' in section:
                    chunkCounter += 1
                    self.writeChunk(baseName, chunkCounter, section['paragraph'])

        return chunkCounter

    def writeChunk(self, baseName, chunkIndex, content):
        """
        Write a single chunk to output directory.
        """
        chunkFileName = f"{baseName}_chunk{chunkIndex}.txt"
        outputFilePath = os.path.join(self.outputPath, chunkFileName)

        with open(outputFilePath, 'w', encoding='utf-8') as outFile:
            outFile.write(content.strip())