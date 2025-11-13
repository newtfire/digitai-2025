import os
import requests
import streamlit as st

API_URL = "http://localhost:8000/digitai-agent"

# Choose your local model name (check with `ollama list`)
MODEL_NAME = "qwen3:8b"  # or change to your installed model name

# ------------------------------
# 🧠 DigitAI Chat UI
# ------------------------------
st.set_page_config(page_title="DigitAI Tutor", page_icon="🧠", layout="centered")

st.title("🧠 DigitAI: TEI/XML Tutor")
st.caption("Ask questions about TEI encoding, markup, and structure.")

# Sidebar info
with st.sidebar:
    st.header("About DigitAI")
    st.markdown(
        """
        DigitAI is a **TEI-aware AI tutor** that helps students and researchers
        understand XML encoding principles. It uses hybrid retrieval (FAISS + Neo4j)
        and a local Ollama model to give grounded, example-based answers.
        """
    )
    st.divider()
    st.markdown(
        "**Try asking:**\n"
        "- How do I encode a poem title in TEI?\n"
        "- What is the purpose of the `<teiHeader>` element?\n"
        "- How do I mark a speaker in a TEI play?\n"
        "- What's the difference between `<div>` and `<seg>`?"
    )

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = [
        {
            "role": "assistant",
            "content": "Hi! I'm DigitAI — your TEI tutor. What would you like to learn about today?"
        }
    ]

# Display chat messages
for msg in st.session_state.messages:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])

# Input box
if prompt := st.chat_input("Ask me a TEI question..."):
    # Add user message
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Display placeholder assistant message while loading
    with st.chat_message("assistant"):
        with st.spinner("Thinking..."):
            try:
                # ✅ Talk directly to Ollama
                response = requests.post(
                    API_URL,
                    json={"model": MODEL_NAME, "prompt": prompt, "stream": False},
                    timeout=120
                )

                if response.status_code == 200:
                    data = response.json()
                    answer = data.get("response", "No response received.")
                else:
                    answer = f"❌ Error {response.status_code}: {response.text}"

            except Exception as e:
                answer = f"⚠️ Error contacting API: {e}"

            st.markdown(answer)

    # Save assistant response to session state
    st.session_state.messages.append({"role": "assistant", "content": answer})