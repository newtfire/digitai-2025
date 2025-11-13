FROM python:3.13-slim

WORKDIR /app
COPY ./src/ /app
COPY ./pyproject.toml /code/pyproject.toml
RUN pip install /code/.

EXPOSE 8000
CMD ["sh", "entrypoint.sh"]