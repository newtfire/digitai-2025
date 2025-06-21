from langchain_community.llms import Ollama
from langchain_ollama import OllamaLLM
from langchain_core.messages import HumanMessage, AIMessage
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
import datetime
from llama_index.readers.file import XMLReader
import xml.etree.ElementTree as ET
from lxml import etree
import re

llm = OllamaLLM(model="llama3.2", temperature=0.5)

log_file = "../output/chat_history15.txt"
dataset_file = "../teiTester-dmJournal.xml"

# Load XML data using LlamaIndex's XMLReader
def load_xml_data(file_path):
  try:
    reader = XMLReader()
    document = reader.load_data(file_path) # Load XML as structured document
    return document[0].text # Extract text content
  except Exception as e:
    return f"Error loading XML with LlamaIndex: {e}"
# Load dataset from XML file
dataset_content = load_xml_data(dataset_file)

chat_history = [dataset_content]

prompt_template = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            f"You are an AI.",
        ),
        MessagesPlaceholder(variable_name="chat_history"),
        ("human", "{input}"),
    ]
)

chain = prompt_template | llm

tree = etree.parse(dataset_file)
root = tree.getroot()

def start_app():
    with open(log_file, "a") as file:
        file.write(f"\n--- Chat started on {datetime.datetime.now()} ---\n")
    while True:
        question = input("You: ")
        if question.lower() == "done":
            with open(log_file, "a") as file:
                file.write("\n--- Chat Ended ---\n")
            print("Chat history saved. Exiting...")
            return
        if question.lower() == "xpath":
            def convert_to_namespace_agnostic_xpath(
                    expression):  # takes the xPath entered and rewrites it so it doesn't have namespace errors
                # Match tokens split by either "/" or "//"
                tokens = re.split(r'(//|/)', expression.strip())  # keep the separators

                xpath_parts = []
                for token in tokens:
                    token = token.strip()
                    if token in ('/', '//'):
                        xpath_parts.append(token)
                    elif token == '':
                        continue
                    elif token.startswith('@') or token in ('text()', 'node()', '*'):
                        xpath_parts.append(token)
                    else:
                        # Handle tag[predicate]
                        match = re.match(r"([a-zA-Z0-9_\-]+)(\[.*\])?", token)
                        if match:
                            tag, predicate = match.groups()
                            local = f"*[(local-name()='{tag}')]"  # Ignores the namespace and matches by tag name only.
                            if predicate:
                                local += predicate
                            xpath_parts.append(local)
                        else:
                            xpath_parts.append(token)

                return ''.join(xpath_parts)

            def start_app():
                tree = etree.parse(dataset_file)
                with open(log_file, "a") as file:
                    file.write(f"\n--- xPath started ---\n")

                print("Type 'exit' to quit.")
                print("Try:  //div[@type='entry']//date/text()")

                while True:
                    user_input = input("Enter XPath: ").strip()
                    with open(log_file, "a") as file:
                        hum = f"\nYou: {user_input}\n"
                        file.write(hum)
                        chat_history.append(HumanMessage(content=hum))
                    if user_input.lower() == "exit":
                        with open(log_file, "a") as file:
                            print("\nxPath history saved. Exiting xPath...\n")
                            file.write(f"\n--- xPath Ended ---\n\n")
                        break

                    # Always convert to namespace-agnostic XPath
                    xpath_expr = convert_to_namespace_agnostic_xpath(user_input)

                    try:
                        results = tree.xpath(xpath_expr)
                        with open(log_file, "a") as file:
                            re = f"\nResult:\n"
                            file.write(re)
                            chat_history.append(AIMessage(content=re))
                        if not results:
                            na = "No results found."
                            print(na)
                            chat_history.append(AIMessage(content=na))
                        else:
                            for idx, result in enumerate(results, start=1):
                                if isinstance(result, etree._Element):
                                    resp = f"{etree.tostring(result, pretty_print=True).decode().strip()}"
                                    print(resp)
                                    with open(log_file, "a") as file:
                                        file.write(f"{resp}\n")
                                        chat_history.append(AIMessage(content=resp))
                                else:
                                    print(f"{result}")
                                    with open(log_file, "a") as file:
                                        file.write(f"{result}\n")
                                        chat_history.append(AIMessage(content=result))
                    except Exception as e:
                        print(f"Invalid XPath expression: {e}")

            if __name__ == "__main__":
                start_app()
        else:
            response = chain.invoke({"input": question, "chat_history": chat_history})
            chat_history.append(HumanMessage(content=question))
            chat_history.append(AIMessage(content=response))
            print("AI:", response)
            with open(log_file, "a") as file:
                file.write(f"You: {question}\n")
                file.write(f"AI: {response}\n")
if __name__ == "__main__":
    start_app()