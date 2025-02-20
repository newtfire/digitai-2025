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

def effify(non_f_str: str): # Changes normal string into f strings
    return eval(f'f"""{non_f_str}"""')

system = 'You are a helpful chatbot who answers questions. Use this file to gain knowledge on TEI rules: {file}'

prompt = 'I need help with coding in TEI. I am not sure whether we are coding the TEI del element correctly around the gap element. Here is the TEI file: {data} Can you provide an example of correctly using del and gap elements from the TEI file?'

temperature = 0

date = datetime.datetime.now()

ollama_response = ollama.chat(model=model, messages=[
  {
    'role': 'system',
    'content': f'{effify(system)} \n', # Makes system into f string
  },
  {
    'role': 'user',
    'content': f'{effify(prompt)} \n', # Makes prompt into f string
  },
],
options = {
  'temperature': temperature
})

response_content = ollama_response['message']['content']

# Not f string:
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

moment = date.strftime("%Y.%m.%d_%H.%M") # Making date and time
textfile = open('./output/' + moment + '.txt', "a", encoding="utf-8") # Creates new text file name with date and time

try: # Creates new text file and puts it into output directory
    with textfile as f:
        f.write(output_string)
    print("Ollama response saved to new text file")
except Exception as e:
    print(f"Error saving to text file: {e}")

print(response_content) # Still print to the console as well.