# Bu Fala Backend Modularizado 2.0

## 📋 Visão Geral

O backend foi completamente reestruturado em uma arquitetura modular para melhor organização, manutenibilidade e escalabilidade. Todas as melhorias da documentação oficial do Gemma-3n foram implementadas.

## 📂 Estrutura do Projeto

```
backend/
├── app.py                      # Aplicação Flask principal
├── run.py                      # Script de inicialização
├── requirements.txt            # Dependências
├── __init__.py                # Inicialização do pacote
│
├── config/
│   └── settings.py            # Configurações centralizadas
│
├── services/
│   └── gemma_service.py       # Serviço principal do Gemma-3n
│
├── routes/
│   ├── health_routes.py       # Rotas de saúde do sistema
│   ├── medical_routes.py      # Rotas médicas
│   ├── education_routes.py    # Rotas educacionais
│   ├── agriculture_routes.py  # Rotas agrícolas
│   ├── wellness_routes.py     # Rotas de bem-estar
│   ├── translation_routes.py  # Rotas de tradução
│   └── environmental_routes.py # Rotas ambientais
│
└── utils/
    ├── logging_config.py      # Configuração de logs
    ├── decorators.py          # Decoradores utilitários
    └── fallback_responses.py  # Respostas de fallback
```

## 🚀 Como Executar

### Opção 1: Script direto
```bash
cd backend
python run.py
```

### Opção 2: Módulo Python
```bash
cd backend
python -m app
```

### Opção 3: Flask CLI
```bash
cd backend
export FLASK_APP=app.py
flask run
```

## 🔧 Melhorias Implementadas

### 1. **Arquitetura Modular**
- **Separação por responsabilidade**: Cada domínio tem sua própria rota
- **Serviços centralizados**: GemmaService gerencia toda a IA
- **Configurações centralizadas**: Todas as configs em um local
- **Utilitários reutilizáveis**: Decorators, logging, fallbacks

### 2. **Melhorias da Documentação Gemma-3n**
- ✅ **Pipeline API oficial**: Método recomendado pelo Google
- ✅ **Chat Templates**: Conversação estruturada oficial
- ✅ **AutoProcessor**: Processamento multimodal preparado
- ✅ **Validação de contexto**: Limite de 32K tokens
- ✅ **Otimizações de produção**: torch.compile, Flash Attention 2
- ✅ **bfloat16**: Precisão otimizada para GPU

### 3. **Sistema de Fallbacks Hierárquico**
1. **Pipeline API** (oficial)
2. **Chat Templates** (oficial) 
3. **Método tradicional** (otimizado)
4. **Fallback estático** (sempre funciona)

### 4. **Logging e Monitoramento**
- Logs estruturados e coloridos
- Métricas de performance por rota
- Status detalhado do modelo
- Debugging facilitado

## 📊 Endpoints Disponíveis

### Saúde do Sistema
- `GET /health` - Status geral do backend

### Domínios Principais
- `POST /medical` - Orientações médicas
- `POST /education` - Orientações educacionais  
- `POST /agriculture` - Orientações agrícolas
- `POST /translate` - Tradução de textos

### Bem-estar (Wellness)
- `POST /wellness/coaching` - Coaching de bem-estar
- `POST /wellness/voice-analysis` - Análise de voz
- `POST /wellness/daily-metrics` - Métricas diárias

### Meio Ambiente
- `POST /environment/diagnosis` - Diagnóstico ambiental
- `POST /environment/recommendations` - Recomendações ambientais
- `POST /plant/audio-diagnosis` - Diagnóstico de plantas por áudio

## 🧪 Testes

### Teste Completo
```bash
python test_modular_backend.py
```

### Teste de Saúde
```bash
curl http://localhost:5000/health
```

### Teste Individual
```bash
curl -X POST http://localhost:5000/medical \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Como prevenir gripe?", "language": "pt-BR"}'
```

## ⚙️ Configurações

### Principais Configurações (config/settings.py)
```python
# Servidor
HOST = "0.0.0.0"
PORT = 5000

# Modelo
MODEL_PATH = "caminho/para/gemma-3n"
MAX_CONTEXT_TOKENS = 32768  # 32K tokens
MAX_NEW_TOKENS = 150

# Performance
USE_CUDA = True
USE_BFLOAT16 = True
ENABLE_OPTIMIZATIONS = True
```

### Configurações de Geração
```python
generation_config = {
    'max_new_tokens': 150,
    'temperature': 0.3,
    'top_p': 0.85,
    'top_k': 40,
    'repetition_penalty': 1.1
}
```

## 📈 Benefícios da Modularização

### 1. **Manutenibilidade**
- Código organizado por responsabilidade
- Fácil localização de bugs
- Testes unitários por módulo

### 2. **Escalabilidade**
- Novos domínios facilmente adicionáveis
- Serviços independentes
- Load balancing preparado

### 3. **Desenvolvimento**
- Múltiplos desenvolvedores podem trabalhar simultaneamente
- Deployments parciais possíveis
- Hot-reloading por módulo

### 4. **Performance**
- Imports otimizados
- Cache por serviço
- Inicialização paralela

## 🔍 Debugging e Logs

### Identificação de Métodos Ativos
Durante execução, os logs mostram qual método está sendo usado:

```
✅ Pipeline API carregado - usando método oficial
💬 Chat Template carregado - usando método oficial  
🔄 Método tradicional otimizado carregado
🆘 Usando fallback estático
```

### Logs de Performance
```
⏱️ Rota medical_guidance executada em 2.34s
⚡ Geração concluída em 1.89s
✂️ Contexto truncado de 35000 para ~32K tokens
```

## 🚨 Tratamento de Erros

### Hierarquia de Fallback
1. **Erro no Pipeline** → Tenta Chat Template
2. **Erro no Chat Template** → Tenta método tradicional  
3. **Erro no tradicional** → Usa fallback estático
4. **Erro geral** → Resposta de emergência

### Respostas de Erro Estruturadas
```json
{
  "error": "Descrição do erro",
  "message": "Mensagem amigável",
  "timestamp": "2025-07-02T10:30:00",
  "status": "error"
}
```

## 🛠️ Desenvolvimento

### Adicionar Nova Rota
1. Criar arquivo em `routes/new_domain_routes.py`
2. Implementar blueprint
3. Registrar em `app.py`
4. Adicionar testes

### Adicionar Novo Serviço
1. Criar arquivo em `services/new_service.py`
2. Injetar em `app.py`
3. Usar via `g.new_service` nas rotas

### Modificar Configurações
- Editar `config/settings.py`
- Reiniciar backend para aplicar

## 📋 Status de Funcionalidades

- [x] **Arquitetura modular** completa
- [x] **Pipeline API** oficial implementado
- [x] **Chat Templates** oficiais implementados
- [x] **Validação de contexto** 32K tokens
- [x] **Otimizações de produção** aplicadas
- [x] **Sistema de fallbacks** hierárquico
- [x] **Logging estruturado** implementado
- [x] **Testes automatizados** criados
- [x] **Documentação** completa
- [ ] **Suporte multimodal** (preparado)
- [ ] **Cache Redis** (futuro)
- [ ] **Monitoramento Prometheus** (futuro)

## 🎯 Próximos Passos

1. **Testar integração Flutter** com nova estrutura
2. **Implementar suporte multimodal** completo
3. **Adicionar cache Redis** para performance
4. **Implementar monitoramento** com métricas
5. **Adicionar testes unitários** por módulo

---

*Documentação atualizada em: 2 de julho de 2025*  
*Versão: 2.0.0 - Backend Modularizado com melhorias Gemma-3n*
