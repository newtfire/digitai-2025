import ollama
# From https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/readers/llama-index-readers-file/llama_index/readers/file/xml
from pathlib import Path
from llama_index.readers.file import XMLReader
from llama_index.core import VectorStoreIndex
import xml.etree.ElementTree as ET

loader = XMLReader()
documents = loader.load_data(file=Path("../p5subset.xml"))

tree = ET.parse("../p5subset.xml")
root = tree.getroot()

for child in root:
    print(child.tag, child.attrib)

# https://www.youtube.com/watch?v=4T4Fr20yzBw
model = 'llama3.2'
model1b = 'llama3.2:1b'
model3b = 'llama3.2:3b'
model70b = 'llama3.3:70b'

prompt = "Using the XMLReader() and document loader, how do I provide you the XML file? It can print the tag names and attributes, but how do I allow llama to read the document as well?"

stream = ollama.chat(
    model=model,
    messages=[{'role': 'user', 'content': prompt}],
    stream=True,
 )

for chunk in stream:
    print(chunk['message']['content'], end='')