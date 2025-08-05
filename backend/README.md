# Moransa Backend - Sistema de IA Offline para Assistência Comunitária

## Visão Geral

O backend do Moransa é um sistema FastAPI robusto que serve como ponte entre o aplicativo Flutter e o modelo Gemma 3n executado via Ollama. Projetado para funcionar 100% offline, oferece APIs especializadas para saúde, educação, agricultura, acessibilidade, sustentabilidade ambiental e validação comunitária.

## Arquitetura Técnica

### Stack Principal
- **Framework**: FastAPI (Python 3.8+)
- **IA Engine**: Gemma 3n via Ollama
- **Banco de Dados**: SQLite (local) + PostgreSQL (validação comunitária)
- **Containerização**: Docker + Docker Compose
- **Documentação**: Swagger/OpenAPI automática

### Estrutura do Projeto

```
backend/
├── app.py                 # Aplicação principal FastAPI
├── config/               # Configurações do sistema
│   ├── settings.py       # Configurações gerais
│   └── system_prompts.py # Prompts especializados por módulo
├── routes/               # Endpoints da API
│   ├── health_routes.py          # Saúde e emergências
│   ├── education_routes.py       # Sistema educacional
│   ├── agriculture_routes.py     # Agricultura e pecuária
│   ├── accessibility_routes.py   # Acessibilidade
│   ├── environmental_routes.py   # Sustentabilidade
│   ├── translation_routes.py     # Tradução e idiomas
│   ├── collaborative_validation_routes.py # Validação comunitária
│   └── multimodal_routes.py      # Processamento multimodal
├── services/             # Lógica de negócio
│   ├── gemma_service.py          # Serviço principal Gemma 3n
│   ├── health_service.py         # Lógica médica especializada
│   ├── accessibility_service.py  # Serviços de acessibilidade
│   └── multimodal_service.py     # Processamento de imagens/áudio
├── database/             # Modelos e migrações
│   ├── validation_models.py      # Modelos de validação
│   └── migrations/               # Scripts SQL
├── utils/                # Utilitários
│   ├── logger.py                 # Sistema de logs
│   ├── validators.py             # Validadores de entrada
│   ├── response_cache.py         # Cache de respostas
│   └── error_handler.py          # Tratamento de erros
└── tests/                # Testes automatizados
```

## Módulos Implementados

### 1. Sistema de Saúde (`health_routes.py`)

**Funcionalidades:**
- Diagnóstico de emergência baseado em sintomas
- Protocolos de parto e saúde materno-infantil
- Primeiros socorros com instruções passo-a-passo
- Identificação de plantas medicinais locais

**Endpoints Principais:**
```python
POST /api/health/emergency-diagnosis
POST /api/health/childbirth-guidance
POST /api/health/first-aid
POST /api/health/medicinal-plants
```

**Configuração Gemma 3n:**
- **Temperature**: 0.2-0.3 (máxima precisão)
- **Max Tokens**: 1000
- **Prompt Especializado**: Protocolos médicos validados

### 2. Sistema Educacional (`education_routes.py`)

**Funcionalidades:**
- Geração de planos de aula adaptados
- Criação de histórias educativas em idiomas locais
- Exercícios personalizados por nível
- Conteúdo STEM simplificado

**Endpoints Principais:**
```python
POST /api/education/lesson-plan
POST /api/education/story-generation
POST /api/education/exercises
POST /api/education/stem-content
```

**Configuração Gemma 3n:**
- **Temperature**: 0.6-0.7 (criatividade controlada)
- **Max Tokens**: 1500
- **Prompt Especializado**: Pedagogia culturalmente adaptada

### 3. Sistema Agrícola (`agriculture_routes.py`)

**Funcionalidades:**
- Diagnóstico de pragas e doenças por imagem
- Análise de saúde do solo
- Calendário agrícola local
- Técnicas de agricultura sustentável

**Endpoints Principais:**
```python
POST /api/agriculture/pest-diagnosis
POST /api/agriculture/soil-analysis
POST /api/agriculture/planting-calendar
POST /api/agriculture/sustainable-practices
```

**Configuração Gemma 3n:**
- **Temperature**: 0.4 (precisão técnica)
- **Max Tokens**: 1200
- **Prompt Especializado**: Conhecimento agronômico local

### 4. Sistema de Acessibilidade (`accessibility_routes.py`)

**Funcionalidades:**
- Descrição de ambientes para deficientes visuais
- Simplificação de textos por nível de alfabetização
- Guias de voz para navegação
- Tradução para linguagem de sinais (texto)

**Endpoints Principais:**
```python
POST /api/accessibility/describe-environment
POST /api/accessibility/simplify-text
POST /api/accessibility/voice-guide
POST /api/accessibility/sign-language
```

### 5. Sistema Ambiental (`environmental_routes.py`)

**Funcionalidades:**
- Identificação de espécies por imagem
- Monitoramento de biodiversidade
- Práticas de reciclagem e sustentabilidade
- Educação ambiental

**Endpoints Principais:**
```python
POST /api/environmental/species-identification
POST /api/environmental/biodiversity-monitoring
POST /api/environmental/recycling-guide
POST /api/environmental/education
```

### 6. Sistema de Validação Comunitária (`collaborative_validation_routes.py`)

**Funcionalidades:**
- Gamificação de traduções
- Sistema de votação por consenso
- Ranking de contribuidores
- Validação de conteúdo médico crítico

**Endpoints Principais:**
```python
POST /api/validation/submit-translation
POST /api/validation/vote-translation
GET /api/validation/leaderboard
POST /api/validation/validate-medical
```

## Serviços Core

### Gemma Service (`gemma_service.py`)

**Características:**
- Conexão otimizada com Ollama
- Pool de conexões para alta performance
- Cache inteligente de respostas
- Fallback para respostas offline
- Monitoramento de performance

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
        # Implementação otimizada
```

### Multimodal Service (`multimodal_service.py`)

**Funcionalidades:**
- Processamento de imagens médicas
- Análise de fotos agrícolas
- Descrição de ambientes para acessibilidade
- Identificação de espécies

### Health Service (`health_service.py`)

**Especialização:**
- Protocolos médicos validados
- Triagem de emergências
- Base de conhecimento de plantas medicinais
- Integração com diretrizes da OMS

## Configurações e Prompts

### System Prompts (`system_prompts.py`)

Cada módulo possui prompts especializados:

```python
HEALTH_SYSTEM_PROMPT = """
Você é um assistente médico especializado em emergências rurais.
Sempre priorize:
1. Segurança do paciente
2. Protocolos validados
3. Instruções claras e simples
4. Quando buscar ajuda médica profissional
"""

EDUCATION_SYSTEM_PROMPT = """
Você é um educador especializado em pedagogia culturalmente adaptada.
Crie conteúdo que:
1. Respeite a cultura local
2. Use exemplos do cotidiano
3. Seja apropriado para a idade
4. Incentive o pensamento crítico
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

## Sistema de Cache e Performance

### Response Cache (`response_cache.py`)

```python
class ResponseCache:
    def __init__(self, ttl: int = 3600):
        self.cache = {}
        self.ttl = ttl
    
    def get_cached_response(self, prompt_hash: str) -> Optional[str]:
        # Implementação de cache com TTL
    
    def cache_response(self, prompt_hash: str, response: str):
        # Armazenamento com timestamp
```

### Performance Metrics (`performance_metrics.py`)

- Tempo de resposta por endpoint
- Uso de memória do modelo
- Taxa de cache hit/miss
- Latência de conexão com Ollama

## Tratamento de Erros

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

## Validadores

### Input Validators (`validators.py`)

```python
class HealthRequestValidator:
    @staticmethod
    def validate_symptoms(symptoms: List[str]) -> bool:
        # Validação de sintomas médicos
    
    @staticmethod
    def validate_emergency_level(level: str) -> bool:
        # Validação de nível de emergência

class EducationRequestValidator:
    @staticmethod
    def validate_age_group(age: str) -> bool:
        # Validação de faixa etária
    
    @staticmethod
    def validate_subject(subject: str) -> bool:
        # Validação de matéria escolar
```

## Logging e Monitoramento

### Logger (`logger.py`)

```python
class MorансaLogger:
    def __init__(self):
        self.setup_logging()
    
    def log_request(self, endpoint: str, params: dict, response_time: float):
        # Log estruturado de requisições
    
    def log_error(self, error: Exception, context: dict):
        # Log detalhado de erros
    
    def log_performance(self, metrics: dict):
        # Métricas de performance
```

## Containerização

### Dockerfile

```dockerfile
FROM python:3.9-slim

WORKDIR /app

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copiar e instalar dependências Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código da aplicação
COPY . .

# Expor porta
EXPOSE 5000

# Comando de inicialização
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

## Instalação e Execução

### Pré-requisitos

1. **Python 3.8+**
2. **Ollama** instalado e rodando
3. **Modelo Gemma 3n** baixado via Ollama

### Instalação Local

```bash
# Clonar repositório
git clone <repo-url>
cd backend

# Criar ambiente virtual
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Instalar dependências
pip install -r requirements.txt

# Configurar Ollama
ollama pull gemma2:9b

# Executar aplicação
uvicorn app:app --host 0.0.0.0 --port 5000 --reload
```

### Execução com Docker

```bash
# Build e execução
docker-compose up --build

# Apenas execução
docker-compose up
```

## Testes

### Estrutura de Testes

```
tests/
├── conftest.py           # Configurações pytest
├── test_health_routes.py # Testes do módulo saúde
├── test_education_routes.py # Testes educação
├── test_gemma_service.py # Testes serviço Gemma
└── test_validators.py    # Testes validadores
```

### Executar Testes

```bash
# Todos os testes
pytest

# Testes específicos
pytest tests/test_health_routes.py

# Com cobertura
pytest --cov=. --cov-report=html
```

## API Documentation

### Swagger UI

Acesse `http://localhost:5000/docs` para documentação interativa completa.

### Exemplo de Uso

```python
import requests

# Diagnóstico de emergência
response = requests.post(
    "http://localhost:5000/api/health/emergency-diagnosis",
    json={
        "symptoms": ["febre alta", "dor abdominal", "vômito"],
        "age": "25",
        "gender": "feminino",
        "language": "crioulo"
    }
)

print(response.json())
```

## Métricas e Monitoramento

### Endpoints de Saúde

```python
GET /health              # Status geral
GET /health/ollama       # Status Ollama
GET /health/database     # Status banco de dados
GET /metrics             # Métricas Prometheus
```

### Logs Estruturados

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "INFO",
  "module": "health",
  "endpoint": "/api/health/emergency-diagnosis",
  "response_time": 1.23,
  "tokens_used": 456,
  "cache_hit": false,
  "language": "crioulo"
}
```

## Segurança

### Medidas Implementadas

1. **Validação rigorosa** de todas as entradas
2. **Rate limiting** por IP
3. **Sanitização** de prompts
4. **Logs de auditoria** completos
5. **Isolamento** de processos via Docker

### Configurações de Segurança

```python
# Rate limiting
from slowapi import Limiter

limiter = Limiter(key_func=get_remote_address)

@app.post("/api/health/emergency-diagnosis")
@limiter.limit("10/minute")
async def emergency_diagnosis(request: Request, data: HealthRequest):
    # Implementação
```

## Roadmap

### Próximas Implementações

1. **Google AI Edge Integration**
   - Otimização para dispositivos móveis
   - Sincronização inteligente
   - Processamento híbrido

2. **Melhorias de Performance**
   - Cache distribuído
   - Load balancing
   - Otimização de modelos

3. **Novos Módulos**
   - Sistema veterinário
   - Gestão comunitária
   - Economia local

4. **Expansão Linguística**
   - Suporte a mais idiomas africanos
   - Reconhecimento de voz
   - Síntese de fala

## Contribuição

### Guidelines

1. **Código**: Seguir PEP 8
2. **Testes**: Cobertura mínima 80%
3. **Documentação**: Docstrings obrigatórias
4. **Commits**: Conventional Commits

### Estrutura de Commit

```
feat(health): adicionar diagnóstico de malária
fix(gemma): corrigir timeout em requisições longas
docs(readme): atualizar instruções de instalação
test(agriculture): adicionar testes para diagnóstico de pragas
```

## Licença

MIT License - Veja LICENSE para detalhes.

## Contato

Para dúvidas técnicas ou contribuições, abra uma issue no repositório.

---

**Moransa Backend** - Levando esperança através da tecnologia para comunidades que mais precisam. 🌍❤️