from fastapi import FastAPI
from digitai_api.src.models.digitai_query import DigitAIQueryInput, DigitAIQueryOutput
from digitai_api.src.utils.async_utils import async_retry
from digitaiCore.rag_pipeline import ask_ollama  # You’ll call this core function

app = FastAPI(
    title="DigitAI Tutor API",
    description="FastAPI backend for the DigitAI TEI-aware tutor.",
)

@async_retry(max_retries=5, delay=1)
async def query_digitai_agent(query: str):
    """Run DigitAI’s hybrid RAG pipeline with retry logic."""
    return await ask_ollama(query)

@app.get("/")
async def get_status():
    return {"status": "DigitAI API running"}

@app.post("/digitai-agent")
async def ask_digitai(query: DigitAIQueryInput) -> DigitAIQueryOutput:
    response = await query_digitai_agent(query.text)
    response["intermediate_steps"] = [str(s) for s in response.get("intermediate_steps", [])]
    return response