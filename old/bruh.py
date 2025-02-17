import ollama
# From https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/readers/llama-index-readers-file/llama_index/readers/file/xml
from pathlib import Path
from llama_index.readers.file import XMLReader
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader, Settings
import xml.etree.ElementTree as ET
from llama_parse import LlamaParse

# other way of loading
# from llama_index import download_loader
# SimpleDirectoryReader = download_loader("SimpleDirectoryReader")

model = 'llama3.2'

loader = XMLReader()
documents = loader.load_data(file=Path("../p5subset.xml"))

tree = ET.parse("../p5subset.xml")

stream = ollama.chat(
    model=model,
    messages=[{'role': 'user', 'content': prompt}],
    stream=True,
 )

for chunk in stream:
    print(chunk['message']['content'], end='')