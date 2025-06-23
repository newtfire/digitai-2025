from langchain_community.llms import Ollama
from langchain_ollama import OllamaLLM
from langchain_core.messages import HumanMessage, AIMessage
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
import datetime
from llama_index.readers.file import XMLReader
from pathlib import Path

llm = OllamaLLM(model="llama3.2")

chat_history = []

log_file = "output/chat_history.txt"
dataset_file = "./p5subset.xml"

prompt_template = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            f"You are an AI named Elisa, you answer questions.",
        ),
        MessagesPlaceholder(variable_name="chat_history"),
        ("human", "{input}"),
    ]
)
chain = prompt_template | llm
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
        response = chain.invoke({"input": question, "chat_history": chat_history})
        chat_history.append(HumanMessage(content=question))
        chat_history.append(AIMessage(content=response))
        print("AI:", response)
        with open(log_file, "a") as file:
            file.write(f"You: {question}\n")
            file.write(f"AI: {response}\n")
if __name__ == "__main__":
    start_app()