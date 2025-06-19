# Importing the ollama module which is a chatbot API.
import ollama
from pathlib import Path
from llama_index.readers.file import XMLReader
from llama_index.core import VectorStoreIndex
import xml.etree.ElementTree as ET
model = 'llama3.2'

# Defining a function that reads a file and returns its content.

loader = XMLReader()

def read_file(file):
    # Try-except block for handling FileNotFoundError exception if the file does not exist.
    try:
        with open(file, 'r') as f:
            data = f.read()   # Reading the file content and storing it in variable "data".
        return data  # Returning the read data.
    except FileNotFoundError:
        print("The file could not be found.")

# Calling the function with a filename as argument to get its content.
file = loader.load_data(file=Path("../p5subset.xml"))
data = read_file('../teiTester-dmJournal.xml')

# print("# Input JSON content with multiple errors")  # Printing the content of the JSON file.
# print(data)  # Printing the content of the JSON file.

# Using ollama's chat method for getting a response from the model 'mistral'. The system role is set to help with coding issues, and user provides the data in JSON format that needs fixing. Temperature option is also provided.
ollama_response = ollama.chat(model=model, messages=[
  {
    'role': 'system',
    'content': 'You are a helpful coding assistant.',
  },
  {
    'role': 'user',
    'content': f'I need help with coding in TEI.  I am not sure whether we are coding the TEI del element correctly around the gap element. Can you advise us? Here is a sample file: \n\n {data}. Can you also provide an example of correctly using del and gap elements from the sample file?'
  },
],
options = {
  #'temperature': 1.5, # very creative
  'temperature': 1.5 # very conservative (good for coding and correct syntax)
})

# Printing the response from ollama.
print(ollama_response['message']['content'])
