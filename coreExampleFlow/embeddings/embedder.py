import os
from sentence_transformers import SentenceTransformer
from digitaiCore.utils.configLoader import ConfigLoader

"""
This class reads chunked text files and generates embeddings using BAAI BGE-m3 model.
"""
class Embedder:
    def __init__(self, config: ConfigLoader, corpusName: str):
        self.inputPath = os.path.join(config.get('dataPaths.chunkedRoot'), corpusName)
        self.embeddingOutputPath = os.path.join(config.get('dataPaths.embeddingRoot'), corpusName)

        os.makedirs(self.embeddingOutputPath, exist_ok=True)

        print("Loading BGE-m3 embedding model...")
        self.model = SentenceTransformer('BAAI/bge-m3')
        print("Model loaded successfully.")

    def processAllChunks(self):
        """
        Process all chunked text files and generate embeddings.
        """
        for fileName in os.listdir(self.inputPath):
            if not fileName.endswith('.txt'):
                continue

            inputFilePath = os.path.join(self.inputPath, fileName)

            with open(inputFilePath, 'r', encoding='utf-8') as f:
                content = f.read().strip()

            embedding = self.model.encode(content, normalize_embeddings=True).tolist()

            self.saveEmbedding(fileName, embedding)
            print(f"Embedded: {fileName}")

    def saveEmbedding(self, fileName, embedding):
        """
        Save the embedding as a JSON array (much better than CSV strings for real numbers).
        """
        outputFile = os.path.join(self.embeddingOutputPath, f"{fileName}.embedding.json")

        with open(outputFile, 'w', encoding='utf-8') as outFile:
            import json
            json.dump(embedding, outFile)