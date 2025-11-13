FROM python:3.13-slim

WORKDIR /app
COPY ./src/ /app
RUN pip install streamlit requests

CMD ["streamlit", "run", "main.py"]