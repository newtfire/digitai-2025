import os
import json
import random
from digitaiCore.utils.configLoader import ConfigLoader

class DatasetBuilder:
    """
    This class builds instruction fine-tuning datasets for Qwen2-8B using ChatML format.
    """

    def __init__(self, config: ConfigLoader, corpusName: str):
        self.extractedPath = os.path.join(config.get('dataPaths.extractedRoot'), corpusName)
        self.outputPath = os.path.join(config.get('dataPaths.finetuneRoot'), corpusName)
        os.makedirs(self.outputPath, exist_ok=True)

    def buildDataset(self):
        """
        Process all documents and create ChatML formatted instruction samples.
        """
        dataset = []

        for fileName in os.listdir(self.extractedPath):
            if not fileName.endswith('.json'):
                continue

            filePath = os.path.join(self.extractedPath, fileName)
            with open(filePath, 'r', encoding='utf-8') as f:
                data = json.load(f)

            # Build synthetic examples from document structure
            docTitle = data.get("title", "Untitled Document")
            example = self.createExample(fileName, docTitle, data)
            dataset.append(example)

        # Write dataset file
        outputFile = os.path.join(self.outputPath, "finetuneData.jsonl")
        with open(outputFile, 'w', encoding='utf-8') as outFile:
            for sample in dataset:
                json.dump(sample, outFile)
                outFile.write('\n')

        print(f"Generated {len(dataset)} fine-tuning samples.")

    def createExample(self, fileName, docTitle, data):
        """
        Create one training example from a document.
        """
        sampleUser = f"In document '{docTitle}', what TEI elements are used to encode the structure?"

        # Simplistic auto-generated "answer" (will improve later)
        answer = "The document uses elements like <div>, <section>, <chapter>, and <para> to represent the structure. Paragraphs are nested inside sections, and chapters group multiple sections."

        # Build ChatML structure
        sample = {
            "messages": [
                {"role": "system", "content": "You are an expert TEI XML coding tutor."},
                {"role": "user", "content": sampleUser},
                {"role": "assistant", "content": answer}
            ]
        }
        return sample