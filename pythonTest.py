import ollama

# https://www.youtube.com/watch?v=4T4Fr20yzBw
model = 'llama3.2'
model1b = 'llama3.2:1b'
model3b = 'llama3.2:3b'
model70b = 'llama3.3:70b'


prompt = "How can I learn more about how TEI handles link associations between documents?"

stream = ollama.chat(
    model=model3b,
    messages=[{'role': 'user', 'content': prompt}],
    stream=True,
)

for chunk in stream:
    print(chunk['message']['content'], end='')