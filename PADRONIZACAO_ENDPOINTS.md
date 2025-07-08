# 📋 Padronização de Endpoints - Bu Fala Backend

## 🔍 Análise dos Problemas Identificados

Após análise detalhada dos endpoints documentados em `ENDPOINTS_BU_FALA.md` e do código do Flutter (`android_app/lib/services/api_service.dart`), foram identificadas várias inconsistências que impedem a comunicação adequada entre o backend e o aplicativo Android.

## ❌ Problemas Encontrados

### 1. **Inconsistência nos Nomes dos Campos**

**Backend retorna:**
```json
{
  "answer": "resposta",
  "domain": "medical",
  "language": "pt-BR",
  "model": "gemma-3n-e2b-it",
  "timestamp": "2024-01-01T10:00:00",
  "status": "success"
}
```

**Flutter espera:**
```json
{
  "domain": "medical",
  "question": "pergunta original",  // ❌ AUSENTE no backend
  "answer": "resposta",
  "language": "portuguese",         // ❌ FORMATO DIFERENTE
  "timestamp": "2024-01-01T10:00:00"
}
```

### 2. **Parâmetros de Entrada Inconsistentes**

**Endpoint `/translate`:**
- Backend espera: `from_language`, `to_language`
- Flutter envia: `sourceLanguage`, `targetLanguage`

**Endpoint `/multimodal`:**
- Backend espera: `image` (base64), `text`
- Flutter envia: `image_url`, `audio_url`, `text`

### 3. **Campos Ausentes no Backend**

- Campo `question` não é retornado pelo backend
- Metadados específicos como `subject`, `level`, `crop_type`, `season` não são consistentes
- Campos de resposta do `/multimodal` não seguem o padrão esperado

### 4. **Endpoints do Backend Modular Não Implementados**

Os endpoints documentados em `backend/controllers/` não estão sendo chamados pelo Flutter:
- `/emergency/analyze`
- `/education/generate`
- `/agriculture/advice`
- `/multimodal/analyze-crop`
- etc.

## ✅ Solução Proposta: Padronização Completa

### 1. **Estrutura Padrão de Resposta**

Todos os endpoints devem retornar a seguinte estrutura:

```json
{
  "success": true,
  "data": {
    "answer": "resposta principal",
    "question": "pergunta original",
    "domain": "medical|education|agriculture|translate|multimodal",
    "language": "pt-BR|crioulo-gb|en",
    "metadata": {
      // Campos específicos do domínio
    }
  },
  "model": "gemma-3n-e2b-it",
  "timestamp": "2024-01-01T10:00:00.000Z",
  "status": "success|error|timeout",
  "error": null // ou mensagem de erro
}
```

### 2. **Padronização por Endpoint**

#### **`/health` (GET)**
```json
{
  "success": true,
  "data": {
    "status": "healthy|degraded|error",
    "model_status": "loaded|loading|error",
    "features": ["medical", "education", "agriculture", "translate", "multimodal"],
    "backend_version": "1.0.0",
    "model_version": "gemma-3n-e2b-it"
  },
  "timestamp": "2024-01-01T10:00:00.000Z"
}
```

#### **`/medical` (POST)**
**Entrada:**
```json
{
  "question": "string (obrigatório)",
  "language": "pt-BR|crioulo-gb|en (opcional, padrão: pt-BR)",
  "context": "string (opcional)",
  "urgency": "low|medium|high|emergency (opcional)"
}
```

**Saída:**
```json
{
  "success": true,
  "data": {
    "answer": "resposta médica",
    "question": "pergunta original",
    "domain": "medical",
    "language": "pt-BR",
    "metadata": {
      "urgency": "medium",
      "confidence": 0.85,
      "emergency_detected": false,
      "recommendations": ["recomendação 1", "recomendação 2"]
    }
  },
  "model": "gemma-3n-e2b-it",
  "timestamp": "2024-01-01T10:00:00.000Z",
  "status": "success"
}
```

#### **`/education` (POST)**
**Entrada:**
```json
{
  "question": "string (obrigatório)",
  "subject": "mathematics|science|history|geography|language|general (opcional)",
  "level": "elementary|middle|high|adult (opcional)",
  "language": "pt-BR|crioulo-gb|en (opcional)"
}
```

**Saída:**
```json
{
  "success": true,
  "data": {
    "answer": "conteúdo educativo",
    "question": "pergunta original",
    "domain": "education",
    "language": "pt-BR",
    "metadata": {
      "subject": "mathematics",
      "level": "elementary",
      "activities": ["atividade 1", "atividade 2"],
      "resources": ["recurso 1", "recurso 2"]
    }
  },
  "model": "gemma-3n-e2b-it",
  "timestamp": "2024-01-01T10:00:00.000Z",
  "status": "success"
}
```

#### **`/agriculture` (POST)**
**Entrada:**
```json
{
  "question": "string (obrigatório)",
  "crop_type": "rice|cashew|mango|vegetables|general (opcional)",
  "season": "dry|rainy|planting|harvest|current (opcional)",
  "language": "pt-BR|crioulo-gb|en (opcional)",
  "location": "string (opcional)"
}
```

**Saída:**
```json
{
  "success": true,
  "data": {
    "answer": "orientação agrícola",
    "question": "pergunta original",
    "domain": "agriculture",
    "language": "pt-BR",
    "metadata": {
      "crop_type": "rice",
      "season": "planting",
      "calendar_info": "informações do calendário",
      "pest_warnings": ["aviso 1", "aviso 2"],
      "best_practices": ["prática 1", "prática 2"]
    }
  },
  "model": "gemma-3n-e2b-it",
  "timestamp": "2024-01-01T10:00:00.000Z",
  "status": "success"
}
```

#### **`/translate` (POST)**
**Entrada:**
```json
{
  "text": "string (obrigatório)",
  "from_language": "pt-BR|crioulo-gb|en|fr (obrigatório)",
  "to_language": "pt-BR|crioulo-gb|en|fr (obrigatório)"
}
```

**Saída:**
```json
{
  "success": true,
  "data": {
    "translated": "texto traduzido",
    "original_text": "texto original",
    "from_language": "pt-BR",
    "to_language": "crioulo-gb",
    "metadata": {
      "confidence": 0.92,
      "detected_language": "pt-BR",
      "alternative_translations": ["alternativa 1", "alternativa 2"]
    }
  },
  "model": "gemma-3n-e2b-it",
  "timestamp": "2024-01-01T10:00:00.000Z",
  "status": "success"
}
```

#### **`/multimodal` (POST)**
**Entrada:**
```json
{
  "text": "string (opcional)",
  "image": "base64_string (opcional)",
  "audio": "base64_string (opcional)",
  "type": "image_analysis|audio_analysis|combined (opcional)",
  "language": "pt-BR|crioulo-gb|en (opcional)",
  "context": "medical|education|agriculture|general (opcional)"
}
```

**Saída:**
```json
{
  "success": true,
  "data": {
    "answer": "análise multimodal",
    "type": "image_analysis",
    "analysis_type": "crop_disease_detection",
    "language": "pt-BR",
    "metadata": {
      "has_image": true,
      "has_audio": false,
      "image_quality": "good",
      "detected_objects": ["folha", "mancha"],
      "confidence": 0.88,
      "recommendations": ["recomendação 1"]
    }
  },
  "model": "gemma-3n-e2b-it",
  "timestamp": "2024-01-01T10:00:00.000Z",
  "status": "success"
}
```

### 3. **Tratamento de Erros Padronizado**

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "VALIDATION_ERROR|TIMEOUT|MODEL_ERROR|INTERNAL_ERROR",
    "message": "Mensagem de erro legível",
    "details": "Detalhes técnicos do erro",
    "suggestions": ["sugestão 1", "sugestão 2"]
  },
  "timestamp": "2024-01-01T10:00:00.000Z",
  "status": "error"
}
```

## 🔧 Implementação das Correções

### 1. **Atualizar Backend (`bufala_gemma3n_backend.py`)**

- Modificar todas as rotas para retornar a estrutura padronizada
- Incluir campo `question` nas respostas
- Padronizar nomes de parâmetros de entrada
- Implementar tratamento de erro consistente

### 2. **Atualizar Flutter (`api_service.dart`)**

- Ajustar classes de resposta para nova estrutura
- Modificar parâmetros de entrada para corresponder ao backend
- Implementar tratamento da nova estrutura de erro
- Adicionar suporte aos novos campos de metadata

### 3. **Implementar Backend Modular**

- Conectar endpoints do `backend/controllers/` ao sistema principal
- Garantir que sigam a mesma padronização
- Implementar roteamento adequado

### 4. **Suporte ao Crioulo da Guiné-Bissau**

- Padronizar código de idioma: `crioulo-gb`
- Implementar detecção automática de idioma
- Garantir respostas consistentes em crioulo

## 🎯 Benefícios da Padronização

1. **Comunicação Consistente**: Elimina erros de parsing entre backend e frontend
2. **Manutenibilidade**: Facilita futuras modificações e debugging
3. **Escalabilidade**: Permite adicionar novos endpoints seguindo o mesmo padrão
4. **Experiência do Usuário**: Respostas mais ricas e informativas
5. **Conformidade com Gemma-3n**: Aproveita melhor as capacidades do modelo
6. **Suporte Multilíngue**: Implementação robusta do crioulo da Guiné-Bissau

## 📝 Próximos Passos

1. Implementar as correções no backend principal
2. Atualizar o ApiService do Flutter
3. Testar todos os endpoints com a nova estrutura
4. Implementar endpoints do backend modular
5. Validar funcionamento com modelo Gemma-3n real
6. Documentar exemplos de uso para cada endpoint

---

> **Nota**: Esta padronização resolve os problemas identificados e garante que o aplicativo Bu Fala funcione corretamente com o modelo Gemma-3n, atendendo aos requisitos do desafio Google Gemma 3n Hackathon.