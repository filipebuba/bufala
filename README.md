# Bu Fala - Assistente de IA para Comunidades Rurais da Guiné-Bissau

![Bu Fala Logo](https://img.shields.io/badge/Bu%20Fala-AI%20Assistant-green?style=for-the-badge)

## 🌍 Sobre o Projeto

O **Bu Fala** é um assistente de inteligência artificial desenvolvido especificamente para ajudar comunidades rurais da Guiné-Bissau em três áreas críticas:

- 🚨 **Emergências Médicas**: Orientações de primeiros socorros e assistência médica básica
- 📚 **Educação**: Materiais educativos adaptados para áreas sem acesso a recursos tradicionais
- 🌾 **Agricultura**: Conselhos agrícolas para proteção de cultivos e otimização de colheitas

### 🎯 Missão

Ajudar comunidades que enfrentam:
- Falta de acesso médico rápido (especialmente para partos)
- Escassez de materiais educativos
- Necessidade de orientação agrícola
- Limitações de conectividade (funciona offline)

## 🚀 Funcionalidades

### 🏥 Assistência Médica de Emergência
- Orientações para partos de emergência
- Primeiros socorros básicos
- Identificação de sintomas críticos
- Instruções passo-a-passo para situações de emergência

### 📖 Suporte Educacional
- Geração de materiais educativos adaptados
- Conteúdo para ensino sem recursos tradicionais
- Suporte para múltiplas línguas locais
- Metodologias de ensino criativas

### 🌱 Consultoria Agrícola
- Identificação e tratamento de pragas
- Calendário de plantio otimizado
- Técnicas de conservação de solo
- Proteção de colheitas

### 🌐 Características Técnicas
- **Modo Offline**: Funciona sem conexão à internet
- **Multilíngue**: Suporte para Crioulo e outras línguas locais
- **Interface Web**: Acessível via navegador
- **API REST**: Integração com outros sistemas
- **Interface Gradio**: Interface interativa para testes

## 🛠️ Tecnologias Utilizadas

- **Backend**: Python + Flask
- **IA**: Transformers (Hugging Face)
- **Interface**: Gradio
- **Modelo**: Microsoft DialoGPT (fallback) / Google Gemma (preferencial)
- **Deployment**: Docker (opcional)

## 📦 Instalação

### Pré-requisitos
- Python 3.8+
- pip
- Git

### Passo a Passo

1. **Clone o repositório**:
```bash
git clone <repository-url>
cd bufala
```

2. **Crie um ambiente virtual**:
```bash
python -m venv .venv
```

3. **Ative o ambiente virtual**:
```bash
# Windows
.venv\Scripts\activate

# Linux/Mac
source .venv/bin/activate
```

4. **Instale as dependências**:
```bash
pip install -r requirements.txt
```

5. **Execute o backend**:
```bash
python bufala_gemma_backend.py
```

## 🚀 Uso

### Iniciando o Servidor

```bash
python bufala_gemma_backend.py
```

O servidor estará disponível em:
- **API Principal**: http://localhost:5000
- **Interface Gradio**: http://localhost:7860
- **Health Check**: http://localhost:5000/health

### Endpoints da API

#### 🔍 Health Check
```http
GET /health
```

#### 💬 Chat Geral
```http
POST /chat
Content-Type: application/json

{
  "message": "Como fazer primeiros socorros?"
}
```

#### 🚨 Análise de Emergência
```http
POST /emergency/analyze
Content-Type: application/json

{
  "symptoms": "Mulher em trabalho de parto com dificuldades"
}
```

#### 📚 Geração de Material Educativo
```http
POST /education/generate
Content-Type: application/json

{
  "topic": "matemática básica",
  "level": "básico"
}
```

#### 🌾 Consultoria Agrícola
```http
POST /agriculture/advice
Content-Type: application/json

{
  "problem": "pragas atacando plantação",
  "crop": "arroz"
}
```

#### 🤖 Informações do Modelo
```http
GET /models
```

#### 🎨 Interface Gradio
```http
GET /gradio
```

## 🧪 Testes

Execute o script de testes para verificar todas as funcionalidades:

```bash
python test_backend.py
```

O script testará:
- ✅ Health check
- ✅ Informações do modelo
- ✅ Chat geral
- ✅ Análise de emergências
- ✅ Geração educativa
- ✅ Consultoria agrícola
- ✅ Interface Gradio

## 📁 Estrutura do Projeto

```
bufala/
├── bufala_gemma_backend.py    # Backend principal
├── gemma3_config.json         # Configurações do modelo
├── test_backend.py            # Script de testes
├── requirements.txt           # Dependências Python
├── README.md                  # Documentação
└── .venv/                     # Ambiente virtual
```

## ⚙️ Configuração

### Arquivo de Configuração (`gemma3_config.json`)

```json
{
  "model_name": "google/gemma-3-2b-it",
  "offline_mode": true,
  "local_model_path": null,
  "max_length": 512,
  "temperature": 0.7,
  "top_p": 0.9,
  "do_sample": true
}
```

### Variáveis de Ambiente

- `HUGGINGFACE_TOKEN`: Token para acesso a modelos restritos
- `KAGGLE_USERNAME`: Usuário Kaggle (opcional)
- `KAGGLE_KEY`: Chave API Kaggle (opcional)

## 🌍 Suporte a Idiomas

O Bu Fala foi projetado para suportar:
- **Português**: Idioma principal
- **Crioulo da Guiné-Bissau**: Idioma local prioritário
- **Outras línguas locais**: Expansão futura

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Roadmap

- [x] **Fase 1**: Backend básico com modelo de fallback ✅
- [ ] **Fase 2**: Integração com modelos Gemma
- [ ] **Fase 3**: Suporte completo ao Crioulo
- [ ] **Fase 4**: App mobile Android
- [ ] **Fase 5**: Modo completamente offline
- [ ] **Fase 6**: Reconhecimento de voz
- [ ] **Fase 7**: Interface em Crioulo

## 🚨 Status Atual

✅ **Funcionando**:
- Backend Flask com API REST
- Modelo DialoGPT carregado com sucesso
- Interface Gradio disponível
- Todas as rotas da API funcionais
- Modo offline ativo
- Testes automatizados

⚠️ **Limitações**:
- Modelo Gemma requer autenticação (usando DialoGPT como fallback)
- Suporte limitado ao Crioulo (em desenvolvimento)
- Interface apenas em Português
- Requer conexão inicial para download de modelos

## 📞 Suporte

Para suporte técnico ou dúvidas:
- Abra uma issue no GitHub
- Entre em contato com a equipe de desenvolvimento

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

- Comunidades rurais da Guiné-Bissau pela inspiração
- Hugging Face pela infraestrutura de IA
- Google pelo modelo Gemma
- Microsoft pelo DialoGPT
- Gradio pela interface interativa

---

**Bu Fala** - *Falando pela sua comunidade* 🌍❤️