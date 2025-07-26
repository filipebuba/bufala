# Bu Fala - Assistente de IA para Comunidades Rurais da Guiné-Bissau

![Bu Fala](https://img.shields.io/badge/Bu%20Fala-AI%20Assistant-green?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## 🌍 Sobre o Projeto

O **Bu Fala** é um assistente de inteligência artificial desenvolvido para ajudar comunidades rurais da Guiné-Bissau que enfrentam desafios críticos em áreas remotas sem acesso adequado a serviços essenciais.

### 🎯 Problemas que Resolvemos

- **🚨 Emergências Médicas**: Muitas mulheres morrem durante o parto porque os médicos não conseguem chegar a tempo
- **📚 Educação**: Existem pessoas qualificadas para ensinar, mas faltam materiais e acesso à internet
- **🌾 Agricultura**: Perdas de colheitas por falta de ferramentas para proteger as culturas
- **🗣️ Idioma**: Necessidade de suporte ao Crioulo e outras línguas locais da Guiné-Bissau

## ✨ Funcionalidades

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

### 🤖 IA Adaptativa
- **Aprendizado Contínuo**: O sistema aprende e se adapta às necessidades locais
- **Multilíngue**: Suporte nativo para Crioulo e outras línguas da Guiné-Bissau
- **Modo Offline**: Funciona mesmo sem conexão à internet
- **Interface Intuitiva**: Fácil de usar mesmo para pessoas com pouca experiência tecnológica

## 🏗️ Arquitetura do Sistema

### Backend (Python + Flask)
- **API REST** com documentação Swagger
- **Modelo de IA** baseado em Gemma 3N
- **Processamento Multimodal** (texto, áudio, imagem)
- **Sistema de Cache** para performance offline

### Frontend (Flutter)
- **App Android** nativo
- **Interface Responsiva** adaptada para diferentes tamanhos de tela
- **Suporte Offline** com sincronização quando disponível
- **Gravação de Áudio** para interação por voz

### Infraestrutura
- **Docker** para deployment
- **Nginx** para proxy reverso
- **Redis** para cache
- **PostgreSQL** para dados persistentes

## 🚀 Como Executar

### Pré-requisitos
- Docker e Docker Compose
- Python 3.11+
- Flutter SDK (para desenvolvimento mobile)

### Execução Rápida com Docker

```bash
# Clone o repositório
git clone <repository-url>
cd bufala

# Execute com Docker Compose
docker-compose up -d
```

### Execução Manual

#### Backend
```bash
cd backend
pip install -r requirements.txt
python app.py
```

#### App Android
```bash
cd android_app
flutter pub get
flutter run
```

## 📱 Endpoints da API

### Documentação Completa
Acesse a documentação Swagger em: `http://localhost:5000/docs`

### Principais Endpoints

- **GET** `/api/health` - Status do sistema
- **POST** `/api/chat` - Chat geral
- **POST** `/api/emergency/analyze` - Análise de emergências médicas
- **POST** `/api/education/generate` - Geração de material educativo
- **POST** `/api/agriculture/advice` - Consultoria agrícola
- **POST** `/api/multimodal/process` - Processamento multimodal

## 🧪 Testes

```bash
# Testes do Backend
cd backend
python -m pytest tests/

# Testes do Flutter
cd android_app
flutter test
```

## 📁 Estrutura do Projeto

```
bu-fala/
├── backend/                 # API Backend (Python/Flask)
│   ├── app.py              # Aplicação principal
│   ├── routes/             # Rotas da API
│   ├── services/           # Serviços de IA
│   ├── utils/              # Utilitários
│   └── tests/              # Testes
├── backend_novo/           # Backend alternativo
├── android_app/            # App Flutter
│   ├── lib/                # Código Dart
│   ├── assets/             # Recursos (imagens, áudio)
│   └── test/               # Testes Flutter
├── database/               # Scripts de banco
├── nginx/                  # Configuração Nginx
├── redis/                  # Configuração Redis
├── docker-compose.yml      # Orquestração Docker
└── README.md               # Este arquivo
```

## 🌐 Tecnologias Utilizadas

- **Backend**: Python, Flask, Transformers, PyTorch
- **Frontend**: Flutter, Dart
- **IA**: Google Gemma 3N, Hugging Face Transformers
- **Banco de Dados**: PostgreSQL, Redis
- **Infraestrutura**: Docker, Nginx
- **Documentação**: Swagger/OpenAPI

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

- Comunidades rurais da Guiné-Bissau que inspiraram este projeto
- Google pelo modelo Gemma
- Hugging Face pela infraestrutura de IA
- Todos os contribuidores que tornaram este projeto possível

---

**Bu Fala** - Falando a língua da sua comunidade, resolvendo problemas reais.