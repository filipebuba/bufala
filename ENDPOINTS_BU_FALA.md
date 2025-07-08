# Documentação de Endpoints - Bu Fala Gemma-3n Backend

## Endpoints do Backend (`bufala_gemma3n_backend.py`)

### 1. `/health` (GET, OPTIONS)

- **Descrição:** Checagem de saúde do backend e do modelo.
- **Recebe:** Nada (GET)
- **Retorna:** Status do backend, status do modelo, timestamp, etc.

### 2. `/medical` (POST)

- **Descrição:** Consulta médica (pergunta e resposta estruturada).
- **Recebe:**
  - `question` ou `query` (string)
  - `language` (string, opcional)
- **Retorna:**
  - `answer` (string)
  - `domain`, `language`, `model`, `timestamp`, `status`

### 3. `/education` (POST)

- **Descrição:** Conteúdo educativo (pergunta e resposta estruturada).
- **Recebe:**
  - `question` ou `query` (string)
  - `subject` (string, opcional)
  - `level` (string, opcional)
  - `language` (string, opcional)
- **Retorna:**
  - `answer` (string)
  - `subject`, `level`, `domain`, `language`, `model`, `timestamp`, `status`

### 4. `/agriculture` (POST)

- **Descrição:** Orientação agrícola (pergunta e resposta estruturada).
- **Recebe:**
  - `question` ou `query` (string)
  - `language` (string, opcional)
  - `crop_type` (string, opcional)
  - `season` (string, opcional)
- **Retorna:**
  - `answer` (string)
  - `domain`, `crop_type`, `season`, `language`, `model`, `timestamp`, `status`

### 5. `/translate` (POST)

- **Descrição:** Tradução de texto entre idiomas.
- **Recebe:**
  - `text` (string)
  - `from_language` (string)
  - `to_language` (string)
- **Retorna:**
  - `translated` (string)
  - `original_text`, `from_language`, `to_language`, `model`, `timestamp`, `status`

### 6. `/multimodal` (POST)

- **Descrição:** Análise multimodal (texto e/ou imagem).
- **Recebe:**
  - `text` (string, opcional)
  - `image` (string/base64, opcional)
  - `type` (string, opcional)
  - `language` (string, opcional)
- **Retorna:**
  - `answer` (string)
  - `type`, `analysis_type`, `has_image`, `language`, `model`, `timestamp`, `status`

### 7. `/wellness/coaching` (POST)

- **Descrição:** Sessão de wellness coaching (bem-estar).
- **Recebe:**
  - `session_type` (string, opcional)
  - `user_data` (dict, opcional)
  - `language` (string, opcional)
- **Retorna:**
  - `coaching_response` (string)
  - `session_type`, `recommendations`, `progress_score`, `language`, `model`, `timestamp`, `status`

### 8. `/wellness/voice-analysis` (POST)

- **Descrição:** Análise vocal para wellness.
- **Recebe:**
  - `voice_data` (dict)
  - `language` (string, opcional)
- **Retorna:**
  - `analysis`, `recommendations`, `timestamp`, `status`

### 9. `/wellness/daily-metrics` (POST)

- **Descrição:** Análise de métricas diárias de wellness.
- **Recebe:**
  - `metrics` (dict)
  - `language` (string, opcional)
- **Retorna:**
  - `wellness_analysis`, `trends`, `recommendations`, `timestamp`, `status`

### 10. `/plant/image-diagnosis` (POST)

- **Descrição:** Diagnóstico de planta por imagem (simulado).
- **Recebe:**
  - `image` (string/base64)
  - `plant_type` (string, opcional)
  - `user_id` (string, opcional)
- **Retorna:**
  - `diagnosis` (dict), `status`

### 11. `/plant/audio-diagnosis` (POST)

- **Descrição:** Diagnóstico de planta por áudio (simulado).
- **Recebe:**
  - `audio` (string/base64)
  - `plant_type` (string, opcional)
  - `user_id` (string, opcional)
- **Retorna:**
  - `diagnosis` (dict), `status`

### 12. `/biodiversity/track` (POST)

- **Descrição:** Rastreamento/catalogação de biodiversidade (simulado).
- **Recebe:**
  - `image` (string/base64)
  - `location` (string)
  - `user_id` (string, opcional)
- **Retorna:**
  - `result` (dict), `status`, `simulated`

### 13. `/recycling/scan` (POST)

- **Descrição:** Escaneamento de recicláveis (simulado).
- **Recebe:**
  - `image` (string/base64)
  - `user_id` (string, opcional)
- **Retorna:**
  - `materials`, `tips`, `gamification`, etc. (a definir)

### 14. `/environmental/education` (GET)

- **Descrição:** Conteúdo educativo ambiental (a implementar).

### 15. `/environmental/alerts` (GET)

- **Descrição:** Alertas ambientais (a implementar).

---

## O que está sendo recebido pelo Flutter (`android_app`)

O app Flutter consome os seguintes endpoints principais:

- `/health`: Verifica status do backend.
- `/medical`: Envia perguntas de emergência e recebe resposta estruturada (campo `answer` e metadados).
- `/education`: Envia perguntas/temas educacionais e recebe conteúdo (`answer`).
- `/agriculture`: Envia perguntas agrícolas e recebe orientação (`answer`).
- `/translate`: Envia texto e idiomas, recebe tradução (`translated`).
- `/multimodal`: Envia texto/imagem/áudio, recebe análise (`answer`).

O Flutter espera sempre respostas JSON com campos padronizados, principalmente o campo `answer` (ou `translated` para tradução), além de metadados como `domain`, `status`, `timestamp`, etc.

---

## Endpoints do Backend Modular (`backend/controllers/`)

### Emergência

- **POST** `/emergency/analyze` — Análise de emergência (entrada: sintomas, descrição, etc.)
- **POST** `/emergency/first-aid` — Orientações de primeiros socorros
- **GET** `/emergency/contacts` — Lista de contatos de emergência

### Educação

- **POST** `/education/generate` — Geração de conteúdo educativo
- **POST** `/education/lesson-plan` — Geração de plano de aula
- **GET** `/education/subjects` — Lista de matérias/disciplinas
- **POST** `/education/activities` — Geração de atividades educativas

### Agricultura

- **POST** `/agriculture/advice` — Orientação agrícola (diagnóstico, recomendações)
- **GET** `/agriculture/calendar` — Calendário agrícola
- **GET** `/agriculture/crops` — Lista de culturas
- **POST** `/agriculture/pest-identification` — Identificação de pragas

### Tradução

- **POST** `/translate` — Tradução de texto
- **GET** `/translate/dictionary` — Dicionário bilíngue
- **GET** `/translate/languages` — Idiomas suportados
- **POST** `/translate/detect` — Detecção de idioma

### Multimodal

- **POST** `/multimodal/analyze-crop` — Análise de imagem de cultura agrícola
- **POST** `/multimodal/emergency-image` — Análise de imagem de emergência
- **POST** `/multimodal/educational-audio` — Processamento de áudio educativo
- **POST** `/multimodal/voice-emergency` — Análise de voz em contexto de emergência
- **POST** `/multimodal/edge-demo` — Demonstração de edge computing

### Chat

- **POST** `/chat` — Chat geral
- **POST** `/chat/context` — Chat com contexto
- **GET** `/chat/suggestions` — Sugestões de chat

### Saúde/Sistema

- **GET** `/health` — Status de saúde do backend
- **GET** `/models` — Informações dos modelos carregados
- **GET** `/status` — Status do sistema
- **POST** `/reload-model` — Recarregar modelo IA

---

> Os endpoints acima são expostos pelo backend modular (FastAPI/Flask), organizados por domínio. Para detalhes de parâmetros e exemplos de payload, consulte os controladores Python em `backend/controllers/`.
