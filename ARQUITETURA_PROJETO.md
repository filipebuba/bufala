# Arquitetura do Projeto Bu Fala

## Visão Geral

O Bu Fala é um assistente de IA desenvolvido para ajudar comunidades rurais da Guiné-Bissau em três áreas críticas: emergências médicas, educação e agricultura. O projeto segue uma arquitetura híbrida com backend Python e aplicativo Android nativo.

## Componentes Principais

### 1. Backend Python Flask

**Arquivo Principal**: `bufala_gemma3n_backend.py`

- **Framework**: Flask com CORS habilitado
- **Modelo de IA**: Google Gemma-3n via Hugging Face Transformers
- **Dispositivo**: Suporte para CPU/GPU com PyTorch
- **Timeout**: Sistema de decoradores para controle de tempo limite
- **Logging**: Sistema centralizado de logs em `bu_fala.log`

#### Endpoints da API

- `GET /health` - Health check do sistema
- `POST /chat` - Chat geral com IA
- `POST /emergency/analyze` - Análise de emergências médicas
- `POST /education/generate` - Geração de material educativo
- `POST /agriculture/advice` - Consultoria agrícola
- `GET /models` - Informações do modelo carregado

### 2. Aplicativo Android

**Tecnologias**: Kotlin + Jetpack Compose + Hilt DI

#### Arquitetura MVVM

- **View**: Telas em Jetpack Compose
- **ViewModel**: Gerenciamento de estado com StateFlow
- **Model**: Repositórios e fontes de dados

#### Funcionalidades Offline

- **TensorFlow Lite**: Modelos ML locais para funcionalidade offline
- **Room Database**: Armazenamento local SQLite
- **Cache Inteligente**: Sistema de cache para conteúdo essencial

#### Recursos Multimodais

- **CameraX**: Captura e análise de imagens
- **MediaPipe**: Processamento multimodal
- **Audio**: Suporte a entrada e saída de voz

### 3. Sistema de Dados

#### Banco de Dados Local

- **SQLite**: `bu_fala.db` para armazenamento principal
- **Room ORM**: Abstração de banco para Android
- **Entidades Principais**:
  - EmergencyCaseEntity
  - EducationalResourceEntity
  - AgriculturalIssueEntity

#### Configurações

- **config.json**: Configurações gerais do sistema
- **gemma3_config.json**: Configurações específicas do modelo Gemma-3n
- **Suporte Multilíngue**: Português, Crioulo, Inglês

## Fluxo de Dados

### 1. Interação Usuário → Backend

```
App Android → HTTP Request → Flask API → Gemma-3n Model → Response → App Android
```

### 2. Modo Offline

```
App Android → TensorFlow Lite Models → Room Database → UI Update
```

### 3. Análise de Imagens

```
CameraX → Image Capture → ML Analysis → Results Display
```

## Tecnologias e Dependências

### Backend Python

- **Flask**: Framework web
- **Transformers**: Biblioteca Hugging Face para IA
- **PyTorch**: Framework de deep learning
- **KaggleHub**: Download de modelos
- **CORS**: Suporte cross-origin

### Android

- **Jetpack Compose**: UI moderna
- **Hilt**: Injeção de dependência
- **Room**: Persistência de dados
- **CameraX**: Funcionalidades de câmera
- **TensorFlow Lite**: ML no dispositivo
- **Navigation Compose**: Navegação

## Padrões de Desenvolvimento

### Convenções de Código

- **Python**: snake_case para funções, PascalCase para classes
- **Android**: camelCase para funções, PascalCase para classes
- **Decoradores**: Timeout handlers em todas as rotas Flask
- **Error Handling**: Respostas consistentes com status 408 para timeouts

### Estrutura de Testes

- **Backend**: `test_backend.py` para todos os endpoints
- **Testes Individuais**: Arquivos `test_*.py` específicos
- **Android**: JUnit + Compose Testing
- **Comandos**:
  - `python test_backend.py` - Testa todos os endpoints
  - `./gradlew test` - Testes unitários Android
  - `./gradlew connectedAndroidTest` - Testes de integração

## Segurança e Performance

### Medidas de Segurança

- **Rate Limiting**: 60 req/min, 1000 req/hora
- **Content Filtering**: Validação de entrada
- **Data Privacy**: Logs anônimos, retenção zero
- **Encrypted Storage**: Dados sensíveis criptografados

### Otimizações

- **Lazy Loading**: Carregamento sob demanda
- **Image Caching**: Cache LRU para imagens
- **Model Optimization**: Configurações otimizadas para Gemma-3n
- **Offline First**: Funcionalidade offline prioritária

## Deployment e Monitoramento

### Comandos de Execução

- **Backend**: `python bufala_gemma3n_backend.py`
- **Android Build**: `./gradlew build`
- **Testes**: `python test_backend.py`

### Monitoramento

- **Logs**: Sistema centralizado em `bu_fala.log`
- **Métricas**: Tracking de uso, performance e erros
- **Health Checks**: Endpoint `/health` para status do sistema

## Comunidades Alvo

### Funcionalidades Específicas

- **Emergências Médicas**: Orientações de primeiros socorros, partos de emergência
- **Educação**: Material didático adaptado, múltiplas disciplinas
- **Agricultura**: Calendário agrícola, identificação de pragas, técnicas de plantio

### Suporte Multilíngue

- **Português**: Idioma principal
- **Crioulo da Guiné-Bissau**: Idioma local prioritário
- **Detecção Automática**: Sistema de detecção de idioma
- **Tradução**: Capacidades de tradução integradas

Esta arquitetura garante escalabilidade, manutenibilidade e funcionalidade offline essencial para servir comunidades rurais com conectividade limitada.
