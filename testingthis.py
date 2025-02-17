import ollama
from pathlib import Path
from llama_index.readers.file import XMLReader
import datetime
from llama_index.core import VectorStoreIndex
import xml.etree.ElementTree as ET
import json

model = 'llama3.2'

loader = XMLReader()

file = loader.load_data(file=Path("./p5subset.xml"))
data = loader.load_data(file=Path('./teiTester-dmJournal.xml'))

file_path = Path("./p5subset.xml")
data_path = Path('./teiTester-dmJournal.xml')

file_name = file_path.name  # Extract filename
data_name = data_path.name  # Extract filename

system = f'You are a helpful chatbot who answers questions. Use this file to gain knowledge on TEI rules: {file_name}'

prompt = f'I need help with coding in TEI. I am not sure whether we are coding the TEI del element correctly around the gap element. Can you also provide an example of correctly using del and gap elements from the TEI file? Here is the TEI file: {data_name}.'

temperature = 0

date = datetime.datetime.now()

ollama_response = ollama.chat(model=model, messages=[
  {
    'role': 'system',
    'content': f'{system}{file}',
  },
  {
    'role': 'user',
    'content': f'{prompt}{data}',
  },
],
options = {
  'temperature': temperature
})

response_content = ollama_response['message']['content']

# Create a dictionary to store the output

output_string = f"""
======================
Model: {model}
Temperature: {temperature}
Date: {date}
System: {system}
Query Excerpt: {prompt}
Response: {response_content}
======================
"""

try:
    with open("./output/ollama_response.txt", "a", encoding="utf-8") as f:
        f.write(output_string)
    print("Ollama response saved to ollama_response.txt")
except Exception as e:
    print(f"Error saving to text file: {e}")

print(response_content) # Still print to the console as well.