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

- **App Mobile**: Flutter (Dart)
- **Backend**: Python (Flask) com APIs REST
- **IA Offline**: Gemma 3n via Ollama
- **Banco Local**: Hive + SharedPreferences
- **Rede**: Dio/HTTP com suporte a modo offline e fallback
- **Síntese de Voz**: Flutter TTS

## Estrutura do Projeto

```
android_app/
├── lib/                    # Código fonte Flutter
├── assets/                 # Fontes e recursos locais
├── test/                   # Testes automatizados
├── android/                # Configurações Android nativas
├── ios/                    # Configurações iOS
├── web/                    # Suporte web para desenvolvimento
└── windows/                # Suporte Windows para desenvolvimento
```

## Instalação e Configuração

### Pré-requisitos
- Flutter SDK 3.10+
- Android Studio
- SDK Android configurado
- Backend do projeto em execução (via Docker recomendado)

### Configuração do Ambiente

```bash
# Na raiz do projeto
cd android_app
flutter pub get
flutter run
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
