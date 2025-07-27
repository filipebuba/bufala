# Configuração de Ambiente - Moransa

## 📋 Visão Geral

Este documento explica como configurar as variáveis de ambiente para o projeto **Moransa** - Sistema de IA para Assistência Comunitária na Guiné-Bissau.

## 🚀 Configuração Inicial

### 1. Copiar o arquivo de exemplo

```bash
cp .env.example .env
```

### 2. Configurar as variáveis essenciais

Edite o arquivo `.env` e configure as seguintes variáveis:

#### 🔐 Credenciais do Kaggle (Obrigatório para Gemma-3n)
```env
KAGGLE_USERNAME=seu_usuario_kaggle
KAGGLE_KEY=sua_chave_kaggle
```

**Como obter as credenciais do Kaggle:**
1. Acesse [kaggle.com](https://www.kaggle.com)
2. Vá em Account → API → Create New API Token
3. Baixe o arquivo `kaggle.json`
4. Use as credenciais do arquivo

#### 🗄️ Banco de Dados
```env
DATABASE_URL=postgresql://usuario:senha@localhost:5432/moransa_db
```

#### 🔴 Redis
```env
REDIS_URL=redis://:senha@localhost:6379/0
```

#### 🔑 Chaves Secretas
```env
SECRET_KEY=sua_chave_secreta_muito_forte
JWT_SECRET_KEY=sua_chave_jwt_muito_forte
```

## 🛠️ Configurações por Ambiente

### Desenvolvimento Local
```env
FLASK_ENV=development
DEBUG=true
LOG_LEVEL=debug
OLLAMA_HOST=http://localhost:11434
```

### Produção
```env
FLASK_ENV=production
DEBUG=false
LOG_LEVEL=info
FORCE_HTTPS=true
OLLAMA_HOST=http://ollama:11434
```

## 🤖 Configurações de IA

### Ollama (Recomendado)
```env
OLLAMA_HOST=http://ollama:11434
OLLAMA_MODEL=gemma2:3b
OLLAMA_TIMEOUT=120
```

### Gemma-3n Local
```env
GEMMA_MODEL_NAME=google/gemma-2-3b-it
GEMMA_DEVICE=auto
GEMMA_MAX_LENGTH=2048
GEMMA_TEMPERATURE=0.7
```

## 🌍 Configurações Específicas da Guiné-Bissau

```env
SUPPORTED_LANGUAGES=pt-BR,pt-GW,crioulo,balanta,fula,mandinga
DEFAULT_LANGUAGE=pt-BR
TIMEZONE=Africa/Bissau
LOCAL_CURRENCY=XOF
CULTURAL_CONTEXT=guinea_bissau
EMERGENCY_CONTACTS=117,118,119
```

## 📊 Monitoramento e Logs

```env
LOG_LEVEL=info
LOG_FILE=/app/logs/moransa.log
SENTRY_DSN=sua_dsn_sentry
SENTRY_ENVIRONMENT=development
```

## 🔒 Segurança

### Configurações CORS
```env
CORS_ENABLED=true
CORS_ORIGINS=http://localhost:3000,https://moransa.app
CORS_ALLOW_CREDENTIALS=true
```

### Rate Limiting
```env
RATE_LIMIT_STORAGE_URL=redis://:senha@redis:6379/1
RATE_LIMIT_DEFAULT=100 per hour
```

## 🐳 Docker

Para usar com Docker Compose, as variáveis são automaticamente carregadas do arquivo `.env`.

```bash
docker-compose up -d
```

## ⚠️ Importantes Considerações de Segurança

1. **NUNCA** commite o arquivo `.env` com credenciais reais
2. Use senhas fortes para todas as credenciais
3. Em produção, configure SSL/HTTPS
4. Mantenha as chaves secretas únicas e seguras
5. Configure monitoramento e alertas adequados
6. Use variáveis de ambiente do sistema em produção

## 🔧 Troubleshooting

### Problema: Erro de conexão com Ollama
**Solução:** Verifique se o Ollama está rodando e a URL está correta
```bash
curl http://localhost:11434/api/version
```

### Problema: Erro de credenciais do Kaggle
**Solução:** Verifique se as credenciais estão corretas e o arquivo kaggle.json existe
```bash
kaggle datasets list --max-size 1
```

### Problema: Erro de conexão com banco de dados
**Solução:** Verifique se o PostgreSQL está rodando e as credenciais estão corretas
```bash
psql $DATABASE_URL -c "SELECT version();"
```

### Problema: Erro de conexão com Redis
**Solução:** Verifique se o Redis está rodando
```bash
redis-cli ping
```

## 📚 Variáveis de Ambiente Completas

Para uma lista completa de todas as variáveis disponíveis, consulte o arquivo `.env.example`.

## 🆘 Suporte

Para problemas de configuração:
1. Verifique os logs em `/app/logs/moransa.log`
2. Consulte a documentação da API em `/docs`
3. Verifique o status dos serviços em `/health`

---

**Moransa** - Assistente de IA para Comunidades da Guiné-Bissau 🇬🇼