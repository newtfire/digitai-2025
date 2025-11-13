from pydantic import BaseModel

class DigitAIQueryInput(BaseModel):
    text: str

class DigitAIQueryOutput(BaseModel):
    input: str
    output: str
    intermediate_steps: list[str]