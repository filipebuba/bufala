# Moransa Backend - Offline AI System for Community Assistance

> 🌍 **English** 🇺🇸 | **[Versão em Português](README.md)** 🇧🇷

> **⚠️ IMPORTANT - PROJECT IN DEVELOPMENT:**
> This project is currently in active development phase. Due to health and financial limitations, it has not been possible to conduct in-person testing with communities in Guinea-Bissau at this time. The functionalities and impact described in this document will be demonstrated through technical videos showing the system in operation. The goal is to validate the concept and architecture before field implementation, which will be carried out as soon as conditions allow.

## Overview

The Moransa backend is a robust FastAPI system that serves as a bridge between the Flutter application and the Gemma 3n model executed via Ollama. Designed to function 100% offline, it offers specialized APIs for health, education, agriculture, accessibility, environmental sustainability, and community validation.

## Technical Architecture

### Main Stack
- **Framework**: FastAPI (Python 3.8+)
- **AI Engine**: Gemma 3n via Ollama
- **Database**: SQLite (local) + PostgreSQL (community validation)
- **Containerization**: Docker + Docker Compose
- **Documentation**: Automatic Swagger/OpenAPI

### Project Structure

```
backend/
├── app.py                 # Main FastAPI application
├── config/               # System configurations
│   ├── settings.py       # General settings
│   └── system_prompts.py # Specialized prompts by module
├── routes/               # API endpoints
│   ├── health_routes.py          # Health and emergencies
│   ├── education_routes.py       # Educational system
│   ├── agriculture_routes.py     # Agriculture and livestock
│   ├── accessibility_routes.py   # Accessibility
│   ├── environmental_routes.py   # Sustainability
│   ├── translation_routes.py     # Translation and languages
│   ├── collaborative_validation_routes.py # Community validation
│   └── multimodal_routes.py      # Multimodal processing
├── services/             # Business logic
│   ├── gemma_service.py          # Main Gemma 3n service
│   ├── health_service.py         # Specialized medical logic
│   ├── accessibility_service.py  # Accessibility services
│   └── multimodal_service.py     # Image/audio processing
├── database/             # Models and migrations
│   ├── validation_models.py      # Validation models
│   └── migrations/               # SQL scripts
├── utils/                # Utilities
│   ├── logger.py                 # Logging system
│   ├── validators.py             # Input validators
│   ├── response_cache.py         # Response cache
│   └── error_handler.py          # Error handling
└── tests/                # Automated tests
```

## Implemented Modules

### 1. Health System (`health_routes.py`)

**Features:**
- Emergency diagnosis based on symptoms
- Childbirth and maternal-child health protocols
- First aid with step-by-step instructions
- Local medicinal plant identification

**Main Endpoints:**
```python
POST /api/health/emergency-diagnosis
POST /api/health/childbirth-guidance
POST /api/health/first-aid
POST /api/health/medicinal-plants
```

**Gemma 3n Configuration:**
- **Temperature**: 0.2-0.3 (maximum precision)
- **Max Tokens**: 1000
- **Specialized Prompt**: Validated medical protocols

### 2. Educational System (`education_routes.py`)

**Features:**
- Adapted lesson plan generation
- Educational story creation in local languages
- Personalized exercises by level
- Simplified STEM content

**Main Endpoints:**
```python
POST /api/education/lesson-plan
POST /api/education/story-generation
POST /api/education/exercises
POST /api/education/stem-content
```

**Gemma 3n Configuration:**
- **Temperature**: 0.6-0.7 (controlled creativity)
- **Max Tokens**: 1500
- **Specialized Prompt**: Culturally adapted pedagogy

### 3. Agricultural System (`agriculture_routes.py`)

**Features:**
- Pest and disease diagnosis by image
- Soil health analysis
- Local agricultural calendar
- Sustainable agriculture techniques

**Main Endpoints:**
```python
POST /api/agriculture/pest-diagnosis
POST /api/agriculture/soil-analysis
POST /api/agriculture/planting-calendar
POST /api/agriculture/sustainable-practices
```

**Gemma 3n Configuration:**
- **Temperature**: 0.4 (technical precision)
- **Max Tokens**: 1200
- **Specialized Prompt**: Local agronomic knowledge

### 4. Accessibility System (`accessibility_routes.py`)

**Features:**
- Environment description for visually impaired
- Text simplification by literacy level
- Voice guides for navigation
- Sign language translation (text)

**Main Endpoints:**
```python
POST /api/accessibility/describe-environment
POST /api/accessibility/simplify-text
POST /api/accessibility/voice-guide
POST /api/accessibility/sign-language
```

### 5. Environmental System (`environmental_routes.py`)

**Features:**
- Species identification by image
- Biodiversity monitoring
- Recycling and sustainability practices
- Environmental education

**Main Endpoints:**
```python
POST /api/environmental/species-identification
POST /api/environmental/biodiversity-monitoring
POST /api/environmental/recycling-guide
POST /api/environmental/education
```

### 6. Community Validation System (`collaborative_validation_routes.py`)

**Features:**
- Translation gamification
- Consensus voting system
- Contributor ranking
- Critical medical content validation

**Main Endpoints:**
```python
POST /api/validation/submit-translation
POST /api/validation/vote-translation
GET /api/validation/leaderboard
POST /api/validation/validate-medical
```

## Core Services

### Gemma Service (`gemma_service.py`)

**Features:**
- Optimized connection with Ollama
- Connection pool for high performance
- Intelligent response caching
- Fallback for offline responses
- Performance monitoring

```python
class GemmaService:
    def __init__(self):
        self.ollama_client = OllamaClient()
        self.response_cache = ResponseCache()
        self.performance_monitor = PerformanceMonitor()
    
    async def generate_response(
        self, 
        prompt: str, 
        temperature: float = 0.5,
        max_tokens: int = 1000,
        module: str = "general"
    ) -> str:
        # Optimized implementation
```

### Multimodal Service (`multimodal_service.py`)

**Features:**
- Medical image processing
- Agricultural photo analysis
- Environment description for accessibility
- Species identification

### Health Service (`health_service.py`)

**Specialization:**
- Validated medical protocols
- Emergency triage
- Medicinal plant knowledge base
- WHO guidelines integration

## Configurations and Prompts

### System Prompts (`system_prompts.py`)

Each module has specialized prompts:

```python
HEALTH_SYSTEM_PROMPT = """
You are a medical assistant specialized in rural emergencies.
Always prioritize:
1. Patient safety
2. Validated protocols
3. Clear and simple instructions
4. When to seek professional medical help
"""

EDUCATION_SYSTEM_PROMPT = """
You are an educator specialized in culturally adapted pedagogy.
Create content that:
1. Respects local culture
2. Uses everyday examples
3. Is age-appropriate
4. Encourages critical thinking
"""
```

### Settings (`settings.py`)

```python
class Settings:
    # Ollama Configuration
    OLLAMA_HOST = "http://localhost:11434"
    OLLAMA_MODEL = "gemma2:9b"
    
    # Performance Settings
    MAX_CONCURRENT_REQUESTS = 5
    REQUEST_TIMEOUT = 30
    CACHE_TTL = 3600
    
    # Database
    DATABASE_URL = "sqlite:///./moransa.db"
    
    # Logging
    LOG_LEVEL = "INFO"
    LOG_FILE = "moransa.log"
```

## Cache and Performance System

### Response Cache (`response_cache.py`)

```python
class ResponseCache:
    def __init__(self, ttl: int = 3600):
        self.cache = {}
        self.ttl = ttl
    
    def get_cached_response(self, prompt_hash: str) -> Optional[str]:
        # Cache implementation with TTL
    
    def cache_response(self, prompt_hash: str, response: str):
        # Storage with timestamp
```

### Performance Metrics (`performance_metrics.py`)

- Response time per endpoint
- Model memory usage
- Cache hit/miss rate
- Ollama connection latency

## Error Handling

### Error Handler (`error_handler.py`)

```python
class MorансaException(Exception):
    def __init__(self, message: str, error_code: str, module: str):
        self.message = message
        self.error_code = error_code
        self.module = module

@app.exception_handler(MorансaException)
async def moransa_exception_handler(request, exc):
    return JSONResponse(
        status_code=400,
        content={
            "error": exc.error_code,
            "message": exc.message,
            "module": exc.module,
            "fallback_available": True
        }
    )
```

## Validators

### Input Validators (`validators.py`)

```python
class HealthRequestValidator:
    @staticmethod
    def validate_symptoms(symptoms: List[str]) -> bool:
        # Medical symptom validation
    
    @staticmethod
    def validate_emergency_level(level: str) -> bool:
        # Emergency level validation

class EducationRequestValidator:
    @staticmethod
    def validate_age_group(age: str) -> bool:
        # Age group validation
    
    @staticmethod
    def validate_subject(subject: str) -> bool:
        # School subject validation
```

## Logging and Monitoring

### Logger (`logger.py`)

```python
class MorансaLogger:
    def __init__(self):
        self.setup_logging()
    
    def log_request(self, endpoint: str, params: dict, response_time: float):
        # Structured request logging
    
    def log_error(self, error: Exception, context: dict):
        # Detailed error logging
    
    def log_performance(self, metrics: dict):
        # Performance metrics
```

## Containerization

### Dockerfile

```dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 5000

# Startup command
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "5000"]
```

### Docker Compose

```yaml
version: '3.8'
services:
  moransa-backend:
    build: .
    ports:
      - "5000:5000"
    environment:
      - OLLAMA_HOST=http://ollama:11434
    depends_on:
      - ollama
    volumes:
      - ./data:/app/data
  
  ollama:
    image: ollama/ollama:latest
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    
volumes:
  ollama_data:
```

## Installation and Execution

### Prerequisites

1. **Python 3.8+**
2. **Ollama** installed and running
3. **Gemma 3n model** downloaded via Ollama

### Local Installation

```bash
# Clone repository
git clone <repo-url>
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt

# Configure Ollama
ollama pull gemma2:9b

# Run application
uvicorn app:app --host 0.0.0.0 --port 5000 --reload
```

### Docker Execution

```bash
# Build and run
docker-compose up --build

# Run only
docker-compose up
```

## Tests

### Test Structure

```
tests/
├── conftest.py           # pytest configurations
├── test_health_routes.py # Health module tests
├── test_education_routes.py # Education tests
├── test_gemma_service.py # Gemma service tests
└── test_validators.py    # Validator tests
```

### Run Tests

```bash
# All tests
pytest

# Specific tests
pytest tests/test_health_routes.py

# With coverage
pytest --cov=. --cov-report=html
```

## API Documentation

### Swagger UI

Access `http://localhost:5000/docs` for complete interactive documentation.

### Usage Example

```python
import requests

# Emergency diagnosis
response = requests.post(
    "http://localhost:5000/api/health/emergency-diagnosis",
    json={
        "symptoms": ["high fever", "abdominal pain", "vomiting"],
        "age": "25",
        "gender": "female",
        "language": "creole"
    }
)

print(response.json())
```

## Metrics and Monitoring

### Health Endpoints

```python
GET /health              # General status
GET /health/ollama       # Ollama status
GET /health/database     # Database status
GET /metrics             # Prometheus metrics
```

### Structured Logs

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "INFO",
  "module": "health",
  "endpoint": "/api/health/emergency-diagnosis",
  "response_time": 1.23,
  "tokens_used": 456,
  "cache_hit": false,
  "language": "creole"
}
```

## Security

### Implemented Measures

1. **Rigorous validation** of all inputs
2. **Rate limiting** per IP
3. **Prompt sanitization**
4. **Complete audit logs**
5. **Process isolation** via Docker

### Security Configurations

```python
# Rate limiting
from slowapi import Limiter

limiter = Limiter(key_func=get_remote_address)

@app.post("/api/health/emergency-diagnosis")
@limiter.limit("10/minute")
async def emergency_diagnosis(request: Request, data: HealthRequest):
    # Implementation
```

## Roadmap

### Next Implementations

1. **Google AI Edge Integration**
   - Mobile device optimization
   - Intelligent synchronization
   - Hybrid processing

2. **Performance Improvements**
   - Distributed cache
   - Load balancing
   - Model optimization

3. **New Modules**
   - Veterinary system
   - Community management
   - Local economy

4. **Language Expansion**
   - Support for more African languages
   - Voice recognition
   - Speech synthesis

## Contributing

### Guidelines

1. **Code**: Follow PEP 8
2. **Tests**: Minimum 80% coverage
3. **Documentation**: Mandatory docstrings
4. **Commits**: Conventional Commits

### Commit Structure

```
feat(health): add malaria diagnosis
fix(gemma): fix timeout in long requests
docs(readme): update installation instructions
test(agriculture): add tests for pest diagnosis
```

## License

MIT License - See LICENSE for details.

## Contact

For technical questions or contributions, open an issue in the repository.

---

**Moransa Backend** - Bringing hope through technology to communities that need it most. 🌍❤️