 **[English Version](README_EN.md)** | **Português** 🇧🇷

# GuinéApp - Aplicativo Comunitário para Guiné-Bissau

> **⚠️ IMPORTANTE - PROJETO EM DESENVOLVIMENTO:**
> Este projeto encontra-se atualmente em fase de desenvolvimento ativo. Devido a limitações de saúde e financeiras, não foi possível realizar testes presenciais com as comunidades na Guiné-Bissau neste momento. As funcionalidades e o impacto descritos neste documento serão demonstrados através de vídeos técnicos que mostram o sistema em operação. O objetivo é validar o conceito e a arquitetura antes da implementação em campo, que será realizada assim que as condições permitirem.

## Visão Geral

O GuinéApp é um aplicativo Android desenvolvido especialmente para comunidades rurais da Guiné-Bissau, focando em três áreas críticas:

1. **Primeiros Socorros** - Assistência médica de emergência em áreas remotas
2. **Educação** - Materiais educacionais offline para professores e alunos
3. **Agricultura** - Proteção de cultivos e técnicas agrícolas

## Características Principais

### 🚑 Módulo de Primeiros Socorros
- Guias de emergência para partos
- Instruções de primeiros socorros com áudio
- Diagnóstico básico por sintomas
- Comunicação de emergência via SMS
- Interface em Crioulo e outras línguas locais

### 📚 Módulo Educacional
- Materiais didáticos offline
- Planos de aula interativos
- Conteúdo em múltiplas línguas
- Sistema de aprendizado adaptativo
- Recursos para professores sem internet

### 🌾 Módulo Agrícola
- Calendário de plantio local
- Identificação de pragas
- Técnicas de proteção de cultivos
- Previsão do tempo offline
- Dicas de irrigação e fertilização

### 🤖 IA Adaptativa
- Aprendizado de línguas locais (Crioulo)
- Reconhecimento de voz em dialetos regionais
- Personalização baseada na comunidade
- Funcionamento offline com sincronização opcional

## Tecnologias Utilizadas

- **Frontend**: React Native / Flutter
- **Backend**: Node.js com Express
- **IA**: TensorFlow Lite para dispositivos móveis
- **Banco de Dados**: SQLite (offline) + MongoDB (sincronização)
- **Reconhecimento de Voz**: Speech-to-Text customizado
- **Síntese de Voz**: Text-to-Speech em Crioulo

## Estrutura do Projeto

```
guine-app/
├── mobile/                 # Aplicativo móvel
│   ├── src/
│   │   ├── components/     # Componentes reutilizáveis
│   │   ├── screens/        # Telas do aplicativo
│   │   ├── services/       # Serviços e APIs
│   │   ├── utils/          # Utilitários
│   │   └── assets/         # Recursos (imagens, áudios)
│   ├── android/            # Configurações Android
│   └── ios/                # Configurações iOS
├── backend/                # Servidor backend
│   ├── api/                # Endpoints da API
│   ├── models/             # Modelos de dados
│   ├── services/           # Lógica de negócio
│   └── ai/                 # Módulos de IA
├── ai-models/              # Modelos de IA customizados
│   ├── language/           # Processamento de linguagem
│   ├── speech/             # Reconhecimento de voz
│   └── medical/            # Diagnóstico médico
└── docs/                   # Documentação
```

## Instalação e Configuração

### Pré-requisitos
- Node.js 18+
- React Native CLI
- Android Studio
- Python 3.8+ (para IA)

### Configuração do Ambiente

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/guine-app.git
cd guine-app

# Instale dependências do backend
cd backend
npm install

# Instale dependências do mobile
cd ../mobile
npm install

# Configure o ambiente Android
react-native run-android
```

## Funcionalidades Detalhadas

### Primeiros Socorros
- **Emergências Obstétricas**: Guias passo-a-passo para partos de emergência
- **Trauma e Ferimentos**: Tratamento de ferimentos comuns
- **Doenças Tropicais**: Identificação e tratamento inicial
- **Comunicação de Emergência**: Sistema de alerta via SMS/rádio

### Educação
- **Biblioteca Offline**: Livros didáticos em formato digital
- **Jogos Educativos**: Aprendizado interativo para crianças
- **Formação de Professores**: Recursos para capacitação
- **Avaliação Adaptativa**: Sistema que se adapta ao nível do aluno

### Agricultura
- **Calendário Agrícola**: Baseado no clima local
- **Identificação de Pragas**: Reconhecimento por imagem
- **Técnicas Sustentáveis**: Métodos ecológicos de cultivo
- **Mercado Local**: Informações sobre preços e demanda

## Contribuição

Este projeto é open-source e aceita contribuições da comunidade. Para contribuir:

1. Faça um fork do projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Abra um Pull Request

## Licença

MIT License - veja o arquivo LICENSE para detalhes.

## Contato

Para mais informações ou suporte, entre em contato através de:
- Email: contato@guineapp.org
- WhatsApp: +245 XXX XXX XXX

---

**Desenvolvido com ❤️ para as comunidades da Guiné-Bissau**