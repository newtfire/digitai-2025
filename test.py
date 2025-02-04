import ollama
# From https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/readers/llama-index-readers-file/llama_index/readers/file/xml
from pathlib import Path
from llama_index.readers.file import XMLReader
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader, Settings
import xml.etree.ElementTree as ET
# from llama_index.embeddings.openai import OpenAIEmbedding

model = 'llama3.2'
model1b = 'llama3.2:1b'
model3b = 'llama3.2:3b'
model70b = 'llama3.3:70b'

Settings.embed_model = model

loader = XMLReader()
documents = loader.load_data(file=Path("./p5subset.xml"))

tree = ET.parse("./p5subset.xml")
root = tree.getroot()

# for child in root:
#    print(child.tag, child.attrib)

index = VectorStoreIndex.from_documents(documents)
query_engine = index.as_query_engine()
response = query_engine.query(
    "What is the title of the document?"
)
# print(response)

stream = ollama.chat(
    model=model,
    messages=[{'role': 'user', 'content': response}],
    stream=True,
 )

for chunk in stream:
    print(chunk['message']['content'], end='')