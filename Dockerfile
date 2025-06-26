FROM python:3.13.5-slim
EXPOSE 8000

# Install uv
RUN pip install --upgrade pip

# We put everything in /app, heroku-style
WORKDIR /app

# Install dependencies
COPY pyproject.toml ./
RUN pip install .

# Start the app
COPY . .
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
