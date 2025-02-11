# Importing the required library (ollama)
import ollama
# From https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/readers/llama-index-readers-file/llama_index/readers/file/xml
from pathlib import Path
from llama_index.readers.file import XMLReader
import xml.etree.ElementTree as ET
# llx-o5vaJNnCv9FQtOwmxwnK5hIq7Dd0zzehQ3kEfuEVJGnnPS4L

loader = XMLReader()
documents = loader.load_data(file=Path("./p5subset.xml"))

tree = ET.parse("./p5subset.xml")

model = 'llama3.2:1b'

# Setting up the model, enabling streaming responses, and defining the input messages
stream = ollama.chat(model=model, messages=[
   {
     'role': 'system',
     'content': tree,
   },
   {
     'role': 'user',
     'content': 'Explain to me the meaning of life?',
   },
])
# Printing out of the generated response
for chunk in stream:
    print(chunk['message']['content'], end='')