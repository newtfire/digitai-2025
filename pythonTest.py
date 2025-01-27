import ollama

# https://www.youtube.com/watch?v=4T4Fr20yzBw
model = 'llama3.2'

prompt = "what color is the sky?"

stream = ollama.chat(
    model=model,
    messages=[{'role': 'user', 'content': prompt}],
    stream=True,
)

for chunk in stream:
    print(chunk['message']['content'], end='')