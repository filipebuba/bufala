# Use Python 3.11 slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    python3-venv \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment venv_gemma
RUN python -m venv venv_gemma

# Activate virtual environment and upgrade pip
RUN /app/venv_gemma/bin/pip install --upgrade pip

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies in virtual environment
RUN /app/venv_gemma/bin/pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p /app/logs

# Expose port
EXPOSE 5000

# Set environment variables
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PYTHONPATH=/app
ENV PATH="/app/venv_gemma/bin:$PATH"
ENV OLLAMA_HOST=http://localhost:11434

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Run the application using the virtual environment
CMD ["/app/venv_gemma/bin/python", "app.py"]