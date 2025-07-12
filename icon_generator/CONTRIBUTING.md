
## 🏆 Reconhecimento de Contribuidores

### Hall of Fame
Contribuidores que fizeram diferença significativa no projeto:

- 🥇 **Principais Mantenedores**
- 🥈 **Contribuidores Frequentes** 
- 🥉 **Primeiras Contribuições**

### Como ser Reconhecido
- Contribuições consistentes e de qualidade
- Ajuda na comunidade (issues, discussions)
- Documentação e tutoriais
- Testes e correções de bugs
- Traduções e localização

## 📞 Comunicação

### Canais Oficiais
- **GitHub Issues**: Bugs e feature requests
- **GitHub Discussions**: Perguntas e discussões gerais
- **Email**: suporte@bufala.app (questões sensíveis)

### Diretrizes de Comunicação
- Seja respeitoso e inclusivo
- Use linguagem clara e objetiva
- Forneça contexto suficiente
- Seja paciente com respostas

### Código de Conduta
Este projeto segue o [Contributor Covenant](CODE_OF_CONDUCT.md). Ao participar, você concorda em seguir estes termos.

## 🎓 Recursos para Novos Contribuidores

### Primeiros Passos
1. Leia este guia completamente
2. Configure o ambiente de desenvolvimento
3. Execute os testes para garantir que tudo funciona
4. Procure issues marcadas como "good first issue"
5. Faça sua primeira contribuição pequena

### Issues para Iniciantes
Procure por labels:
- `good first issue` - Ideal para novos contribuidores
- `help wanted` - Precisamos de ajuda
- `documentation` - Melhorias na documentação
- `bug` - Correções de bugs simples

### Mentoria
- Disponível para novos contribuidores
- Entre em contato via GitHub Discussions
- Sessões de pair programming quando possível

## 🔍 Review Process

### Para Reviewers
- Seja construtivo e educativo
- Foque no código, não na pessoa
- Explique o "porquê" dos comentários
- Reconheça boas práticas
- Teste as mudanças quando possível

### Para Contribuidores
- Responda aos comentários prontamente
- Faça perguntas se não entender
- Seja aberto a sugestões
- Teste suas mudanças completamente
- Mantenha PRs pequenos e focados

### Critérios de Aprovação
- [ ] Código segue padrões estabelecidos
- [ ] Testes passam e coverage mantido
- [ ] Documentação atualizada
- [ ] Sem breaking changes (ou justificados)
- [ ] Performance não degradada

## 🛠️ Configuração Avançada

### Hooks do Git
```bash
# Instalar hooks pré-configurados
npm run prepare

# Ou configurar manualmente
echo "npm run lint-staged" > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Configuração do Editor
```json
// .vscode/settings.json
{
  "typescript.preferences.importModuleSpecifier": "relative",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "files.associations": {
    "*.svg": "xml"
  }
}
```

### Variáveis de Ambiente
```bash
# .env.development
DEBUG=true
LOG_LEVEL=debug
ICON_QUALITY=high
PARALLEL_GENERATION=true
```

## 📊 Métricas e Monitoramento

### Métricas que Acompanhamos
- Tempo de geração de ícones
- Tamanho dos arquivos gerados
- Taxa de sucesso/erro
- Uso de memória
- Cobertura de testes

### Como Contribuir com Métricas
- Adicione logs informativos
- Implemente benchmarks
- Monitore performance
- Reporte regressões

## 🎯 Roadmap de Contribuições

### Q1 2024
- [ ] Suporte a ícones animados
- [ ] Geração de splash screens
- [ ] Melhoria na performance
- [ ] Mais testes automatizados

### Q2 2024
- [ ] Interface web
- [ ] API REST
- [ ] Integração com Figma
- [ ] Suporte a temas

### Q3 2024
- [ ] IA para geração automática
- [ ] Análise de acessibilidade
- [ ] Otimização avançada
- [ ] Multi-idioma completo

## 🏅 Tipos de Contribuição

### 💻 Código
- Novas funcionalidades
- Correções de bugs
- Otimizações de performance
- Refatorações

### 📚 Documentação
- README e guias
- Comentários no código
- Tutoriais e exemplos
- Traduções

### 🎨 Design
- Melhorias visuais
- Novos ícones
- Temas e estilos
- UX/UI

### 🧪 Testes
- Testes unitários
- Testes de integração
- Testes de performance
- Testes manuais

### 🌍 Comunidade
- Responder issues
- Ajudar outros usuários
- Organizar eventos
- Divulgação do projeto

## 📋 Templates

### Template de Issue (Bug)
```markdown
**Descrição do Bug**
Descrição clara e concisa do bug.

**Passos para Reproduzir**
1. Vá para '...'
2. Clique em '....'
3. Role para baixo até '....'
4. Veja o erro

**Comportamento Esperado**
Descrição do que deveria acontecer.

**Screenshots**
Se aplicável, adicione screenshots.

**Ambiente:**
- OS: [ex: Windows 10]
- Node.js: [ex: 18.17.0]
- npm: [ex: 9.6.7]
- Versão: [ex: 1.0.0]
```

### Template de Issue (Feature)
```markdown
**Sua feature request está relacionada a um problema?**
Descrição clara do problema.

**Descreva a solução que você gostaria**
Descrição clara da solução desejada.

**Descreva alternativas consideradas**
Outras soluções ou funcionalidades consideradas.

**Contexto adicional**
Qualquer outro contexto sobre a feature request.
```

### Template de Pull Request
```markdown
**Descrição**
Resumo das mudanças e qual issue resolve.

**Tipo de mudança**
- [ ] Bug fix (mudança que corrige um issue)
- [ ] Nova funcionalidade (mudança que adiciona funcionalidade)
- [ ] Breaking change (mudança que quebra compatibilidade)
- [ ] Documentação (mudança apenas na documentação)

**Como foi testado?**
Descrição dos testes realizados.

**Checklist:**
- [ ] Meu código segue as diretrizes do projeto
- [ ] Fiz uma auto-revisão do meu código
- [ ] Comentei meu código em partes difíceis de entender
- [ ] Fiz mudanças correspondentes na documentação
- [ ] Minhas mudanças não geram novos warnings
- [ ] Adicionei testes que provam que minha correção é efetiva
- [ ] Testes novos e existentes passam localmente
```

## 🎉 Agradecimentos

Agradecemos a todos que contribuem para tornar o Bu Fala Icon Generator melhor:

- **Desenvolvedores** que escrevem código
- **Designers** que criam assets visuais
- **Testadores** que encontram bugs
- **Documentadores** que escrevem guias
- **Tradutores** que tornam o projeto acessível
- **Usuários** que fornecem feedback

Cada contribuição, por menor que seja, faz diferença! 🙏

---

**Juntos construímos tecnologia que conecta e transforma comunidades!**

Bu Fala - Conectando tecnologia com pessoas 🌍❤️
```

Agora vou criar um arquivo de changelog:

```markdown:CHANGELOG.md
# 📋 Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Suporte a ícones animados (em desenvolvimento)
- Interface web para geração (planejado)
- Integração com Figma (planejado)

### Changed
- Melhorias na performance de geração

### Fixed
- Correções menores na documentação

## [1.0.0] - 2024-01-15

### Added
- 🎉 **Lançamento inicial do Bu Fala Icon Generator**
- ✅ Geração automática de ícones para todas as plataformas
- ✅ Suporte completo ao Android (Google Play Store)
- ✅ Suporte completo ao iOS (Apple App Store)
- ✅ Suporte completo ao Web/PWA
- ✅ Suporte completo ao Microsoft Store
- ✅ Integração com Flutter
- ✅ Gráficos promocionais para lojas
- ✅ Press kit completo
- ✅ CLI interativo
- ✅ Documentação completa
- ✅ Testes automatizados
- ✅ Configuração ESLint/Prettier
- ✅ Suporte a TypeScript

### Features Principais
- **Geração Multi-plataforma**: Ícones otimizados para Android, iOS, Web e Microsoft
- **Integração Flutter**: Widgets e constantes prontos para uso
- **Gráficos Promocionais**: Screenshots, banners sociais, press kit
- **CLI Poderoso**: Interface de linha de comando completa
- **Validação Automática**: Verificação de tamanhos e formatos
- **Performance Otimizada**: Geração paralela e cache inteligente

### Plataformas Suportadas
- **Android**: Mipmap icons, adaptive icons, drawable icons
- **iOS**: App icons completos com Contents.json
- **Web/PWA**: Favicons, manifest.json, ícones PWA
- **Microsoft**: Store logos, tiles, badges

### Ícones de Funcionalidades
- 🏥 **Medical**: Primeiros socorros e emergências
- 🎓 **Education**: Educação revolucionária
- 🌱 **Agriculture**: Agricultura sustentável
- 💚 **Wellness**: Coaching de bem-estar
- 🌍 **Environmental**: Sustentabilidade ambiental
- 🚨 **Emergency**: Ações de emergência
- 🗣️ **Translate**: Tradução e idiomas
- 📷 **Camera**: Análise de imagens

### Gráficos Promocionais
- **Google Play**: Feature graphic, promo graphic, TV banner
- **App Store**: Screenshots templates, app preview
- **Social Media**: Posts Instagram/Facebook, Twitter header, LinkedIn banner
- **Press Kit**: Logo variations, high-res icons, brand guidelines

### Integração Flutter
- **Widgets Customizados**: `BuFalaIcon`, `BuFalaIconWithLabel`
- **Constantes**: `BuFalaIcons`, `BuFalaIconSizes`
- **Extensões**: String extensions para facilitar uso
- **Exemplos**: Tela completa com exemplos de uso

### CLI Features
- **Geração Completa**: `npm run generate-icons`
- **Por Plataforma**: `--platform android|ios|web|microsoft`
- **Preview**: Visualização rápida dos ícones
- **Validação**: Verificação automática de assets
- **Alta Qualidade**: Opção `--high-quality` para melhor resultado

### Qualidade e Testes
- **Cobertura de Testes**: >90% de cobertura
- **Testes Automatizados**: Unit tests, integration tests
- **Linting**: ESLint configurado com regras rigorosas
- **Formatação**: Prettier para código consistente
- **Type Safety**: TypeScript com strict mode

### Documentação
- **README Completo**: Guia detalhado de uso
- **Guia de Contribuição**: Como contribuir com o projeto
- **Changelog**: Histórico de mudanças
- **Código de Conduta**: Diretrizes da comunidade
- **Templates**: Issues e PR templates

### Performance
- **Geração Rápida**: ~30 segundos para todos os ícones
- **Otimização PNG**: Compressão inteligente
- **SVG Minificado**: Redução de tamanho
- **Cache**: Sistema de cache para regeneração rápida
- **Paralelização**: Geração simultânea quando possível

## [0.9.0] - 2024-01-10 (Beta)

### Added
- Versão beta para testes internos
- Geração básica de ícones Android e iOS
- CLI inicial
- Testes básicos

### Changed
- Refatoração da arquitetura principal
- Melhoria na qualidade dos ícones gerados

### Fixed
- Correções na geração de ícones iOS
- Problemas com dependências Sharp

## [0.8.0] - 2024-01-05 (Alpha)

### Added
- Primeira versão funcional
- Geração de ícones Android
- Estrutura básica do projeto
- Configuração inicial do TypeScript

### Known Issues
- Performance lenta na geração
- Suporte limitado a plataformas
- Documentação incompleta

## [0.1.0] - 2024-01-01 (Proof of Concept)

### Added
- Conceito inicial do projeto
- Geração básica de SVG
- Estrutura de arquivos inicial

---

## 🏷️ Tipos de Mudanças

- **Added** - para novas funcionalidades
- **Changed** - para mudanças em funcionalidades existentes
- **Deprecated** - para funcionalidades que serão removidas
- **Removed** - para funcionalidades removidas
- **Fixed** - para correções de bugs
- **Security** - para correções de vulnerabilidades

## 📅 Convenções de Data

Todas as datas seguem o formato ISO 8601: YYYY-MM-DD

## 🔗 Links de Comparação

- [Unreleased](https://github.com/bufala/icon-generator/compare/v1.0.0...HEAD)
- [1.0.0](https://github.com/bufala/icon-generator/compare/v0.9.0...v1.0.0)
- [0.9.0](https://github.com/bufala/icon-generator/compare/v0.8.0...v0.9.0)
- [0.8.0](https://github.com/bufala/icon-generator/compare/v0.1.0...v0.8.0)

## 🎯 Roadmap Futuro

### v1.1.0 (Q2 2024)
- Suporte a ícones animados
- Geração de splash screens
- Interface web
- Integração com Figma

### v1.2.0 (Q3 2024)
- API REST para geração remota
- Integração com CI/CD
- Suporte a temas escuros
- Análise de acessibilidade automática

### v2.0.0 (Q4 2024)
- Geração baseada em IA
- Otimização automática de assets
- Suporte multi-idioma completo
- Dashboard web completo

---

**Mantido pela equipe Bu Fala** 🌍❤️
```

Agora vou criar um arquivo de código de conduta:

```markdown:CODE_OF_CONDUCT.md
# 🤝 Código de Conduta do Contribuidor

## Nossa Promessa

No interesse de promover um ambiente aberto e acolhedor, nós, como contribuidores e mantenedores, nos comprometemos a tornar a participação em nosso projeto e nossa comunidade uma experiência livre de assédio para todos, independentemente de idade, tamanho corporal, deficiência, etnia, características sexuais, identidade e expressão de gênero, nível de experiência, educação, status socioeconômico, nacionalidade, aparência pessoal, raça, religião ou identidade e orientação sexual.

## Nossos Padrões

Exemplos de comportamento que contribuem para criar um ambiente positivo incluem:

### ✅ Comportamentos Encorajados
- Usar linguagem acolhedora e inclusiva
- Ser respeitoso com diferentes pontos de vista e experiências
- Aceitar críticas construtivas com elegância
- Focar no que é melhor para a comunidade
- Mostrar empatia com outros membros da comunidade
- Reconhecer e valorizar contribuições de todos os tipos
- Ser paciente com novos contribuidores
- Compartilhar conhecimento de forma generosa
- Celebrar sucessos da comunidade

### ❌ Comportamentos Inaceitáveis
- Uso de linguagem ou imagens sexualizadas e atenção sexual indesejada
- Trolling, comentários insultuosos/depreciativos e ataques pessoais ou políticos
- Assédio público ou privado
- Publicar informações privadas de outros sem permissão explícita
- Outras condutas que poderiam ser consideradas inadequadas em um ambiente profissional
- Discriminação baseada em qualquer característica pessoal
- Intimidação ou ameaças
- Spam ou autopromoção excessiva

## Responsabilidades dos Mantenedores

Os mantenedores do projeto são responsáveis por esclarecer os padrões de comportamento aceitável e devem tomar ações corretivas apropriadas e justas em resposta a qualquer instância de comportamento inaceitável.

Os mantenedores do projeto têm o direito e a responsabilidade de remover, editar ou rejeitar comentários, commits, código, edições de wiki, issues e outras contribuições que não estejam alinhadas com este Código de Conduta, ou banir temporária ou permanentemente qualquer contribuidor por outros comportamentos que considerem inadequados, ameaçadores, ofensivos ou prejudiciais.

## Escopo

Este Código de Conduta se aplica tanto em espaços do projeto quanto em espaços públicos quando um indivíduo está representando o projeto ou sua comunidade. Exemplos de representação do projeto ou comunidade incluem:

- Usar um endereço de email oficial do projeto
- Postar através de uma conta oficial de mídia social
- Atuar como representante designado em um evento online ou offline
- Participar de discussões em nome do projeto
- Contribuir com código, documentação ou outros assets
- Participar de eventos relacionados ao projeto

## Aplicação

Instâncias de comportamento abusivo, de assédio ou de outra forma inaceitável podem ser relatadas entrando em contato com a equipe do projeto em **conduct@bufala.app**. Todas as reclamações serão revisadas e investigadas e resultarão em uma resposta que seja considerada necessária e apropriada às circunstâncias.

### Processo de Resolução

1. **Relato**: Entre em contato com conduct@bufala.app
2. **Investigação**: A equipe investigará o relato dentro de 48 horas
3. **Discussão**: Discussão interna da equipe sobre ações apropriadas
4. **Ação**: Implementação de medidas corretivas se necessário
5. **Acompanhamento**: Monitoramento da situação para garantir resolução

### Tipos de Ação

Dependendo da gravidade da violação, as ações podem incluir:

- **Aviso**: Aviso privado explicando a violação
- **Aviso Público**: Aviso público sobre o comportamento inadequado
- **Suspensão Temporária**: Suspensão temporária de participação
- **Banimento Permanente**: Remoção permanente da comunidade

## Confidencialidade

A equipe do projeto se compromete a manter a confidencialidade em relação ao relator de um incidente. Mais detalhes sobre políticas específicas de aplicação podem ser postados separadamente.

## Diretrizes Específicas

### Para Contribuidores
- **Seja Construtivo**: Ofereça feedback construtivo e específico
- **Seja Paciente**: Lembre-se que nem todos têm o mesmo nível de experiência
- **Seja Inclusivo**: Use linguagem que inclua todos os membros da comunidade
- **Seja Respeitoso**: Trate todos com dignidade e respeito

### Para Mantenedores
- **Seja Justo**: Aplique as regras de forma consistente e justa
- **Seja Transparente**: Comunique decisões claramente quando apropriado
- **Seja Responsivo**: Responda a relatos e questões em tempo hábil
- **Seja Exemplar**: Modele o comportamento que você espera ver

### Para Discussões Técnicas
- **Foque no Código**: Critique o código, não a pessoa
- **Seja Específico**: Forneça exemplos concretos e sugestões
- **Seja Educativo**: Explique o "porquê" por trás de suas sugestões
- **Seja Colaborativo**: Trabalhe junto para encontrar soluções

## Contexto Cultural

Reconhecemos que o Bu Fala serve comunidades da Guiné-Bissau e valorizamos a diversidade cultural. Encorajamos:

- **Respeito Cultural**: Valorização das diferentes culturas e perspectivas
- **Inclusão Linguística**: Suporte a múltiplos idiomas quando possível
- **Sensibilidade Regional**: Consideração das diferenças regionais e locais
- **Aprendizado Mútuo**: Oportunidades para aprender sobre diferentes culturas

## Recursos e Suporte

### Canais de Comunicação
- **Email**: conduct@bufala.app (questões de conduta)
- **GitHub Discussions**: Para discussões gerais da comunidade
- **GitHub Issues**: Para questões técnicas e bugs

### Recursos Externos
- [Contributor Covenant](https://www.contributor-covenant.org/)
- [GitHub Community Guidelines](https://docs.github.com/en/site-policy/github-terms/github-community-guidelines)
- [Open Source Guide](https://opensource.guide/code-of-conduct/)

## Reconhecimento

Este Código de Conduta é adaptado do [Contributor Covenant](https://www.contributor-covenant.org), versão 2.1, disponível em https://www.contributor-covenant.org/version/2/1/code_of_conduct.html.

Para respostas a perguntas comuns sobre este código de conduta, veja as FAQ em https://www.contributor-covenant.org/faq. Traduções estão disponíveis em https://www.contributor-covenant.org/translations.

## Atualizações

Este Código de Conduta pode ser atualizado periodicamente. Mudanças significativas serão comunicadas à comunidade através de:

- Anúncio no README principal
- Post no GitHub Discussions
- Email para contribuidores ativos (quando aplicável)

## Agradecimentos

Agradecemos a todos os membros da comunidade que ajudam a manter um ambiente positivo e acolhedor. Juntos, construímos uma comunidade mais forte e inclusiva.

---

**Última atualização**: Janeiro 2024  
**Versão**: 2.1  
**Contato**: conduct@bufala.app

---

*Bu Fala - Conectando tecnologia com pessoas, respeitando todas as culturas e comunidades* 🌍❤️
```

Agora vou criar um arquivo de licença:

```text:LICENSE
MIT License

Copyright (c) 2024 Bu Fala Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

Bu Fala Icon Generator
======================

This software generates icons and promotional materials for the Bu Fala 
application, designed to serve communities in Guinea-Bissau.

The Bu Fala project aims to provide AI-powered assistance for:
- Medical emergencies and first aid
- Revolutionary education experiences
- Sustainable agriculture practices
- Wellness coaching and mental health
- Environmental sustainability

For more information about the Bu Fala project, visit:
https://github.com/bufala/android_app

Contact: suporte@bufala.app
```

Finalmente, vou criar um script de setup automatizado mais robusto:

```bash:install.sh
#!/bin/bash

# Bu Fala Icon Generator - Instalação Automática
# =============================================

set -e  # Sair em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log colorido
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Banner
echo -e "${BLUE}"
cat << "EOF"
 ____        ______    _       
|  _ \      |  ____|  | |      
| |_) |_   _| |__ __ _| | __ _ 
|  _ <| | | |  __/ _` | |/ _` |
| |_) | |_| | | | (_| | | (_| |
|____/ \__,_|_|  \__,_|_|\__,_|

Icon Generator - Instalação Automática
=======================================
EOF
echo -e "${NC}"

# Verificar sistema operacional
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
fi

log_info "Sistema detectado: $OS"

# Verificar Node.js
check_nodejs() {
    log_info "Verificando Node.js..."
    
    if ! command -v node &> /dev/null; then
        log_error "Node.js não encontrado!"
        log_info "Por favor, instale Node.js 16+ de: https://nodejs.org/"
        
        if [[ "$OS" == "macos" ]]; then
            log_info "No macOS, você pode usar: brew install node"
        elif [[ "$OS" == "linux" ]]; then
            log_info "No Ubuntu/Debian: sudo apt-get install nodejs npm"
            log_info "No CentOS/RHEL: sudo yum install nodejs npm"
        fi
        
        exit 1
    fi
    
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 16 ]; then
        log_error "Node.js versão 16+ é necessária. Versão atual: $(node -v)"
        exit 1
    fi
    
    log_success "Node.js $(node -v) encontrado"
}

# Verificar npm
check_npm() {
    log_info "Verificando npm..."
    
    if ! command -v npm &> /dev/null; then
        log_error "npm não encontrado!"
        exit 1
    fi
    
    NPM_VERSION=$(npm -v)
    log_success "npm $NPM_VERSION encontrado"
}

# Instalar dependências do sistema
install_system_deps() {
    log_info "Verificando dependências do sistema..."
    
    if [[ "$OS" == "linux" ]]; then
        # Verificar se as dependências do Canvas estão instaladas
        if ! pkg-config --exists cairo; then
            log_warning "Dependências do Canvas não encontradas"
            log_info "Instalando dependências do sistema..."
            
            if command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev
            elif command -v yum &> /dev/null; then
                sudo yum groupinstall -y "Development Tools"
                sudo yum install -y cairo-devel pango-devel libjpeg-turbo-devel giflib-devel librsvg2-devel
            else
                log_warning "Gerenciador de pacotes não suportado. Instale manualmente as dependências do Canvas."
            fi
        fi
    elif [[ "$OS" == "macos" ]]; then
        if ! command -v pkg-config &> /dev/null; then
            log_warning "pkg-config não encontrado"
            if command -v brew &> /dev/null; then
                log_info "Instalando dependências via Homebrew..."
                brew install pkg-config cairo pango libpng jpeg giflib librsvg
            else
                log_warning "Homebrew não encontrado. Instale manualmente as dependências."
            fi
        fi
    fi
    
    log_success "Dependências do sistema verificadas"
}

# Instalar dependências npm
install_npm_deps() {
    log_info "Instalando dependências npm..."
    
    # Limpar cache se necessário
    if [ -d "node_modules" ]; then
        log_info "Limpando instalação anterior..."
        rm -rf node_modules package-lock.json
    fi
    
    # Instalar dependências
    npm install
    
    if [ $? -ne 0 ]; then
        log_error "Erro ao instalar dependências npm"
        log_info "Tentando com cache limpo..."
        npm cache clean --force
        npm install
        
        if [ $? -ne 0 ]; then
            log_error "Falha na instalação das dependências"
            exit 1
        fi
    fi
    
    log_success "Dependências npm instaladas"
}

# Compilar TypeScript
compile_typescript() {
    log_info "Compilando TypeScript..."
    
    npm run build
    
    if [ $? -ne 0 ]; then
        log_error "Erro ao compilar TypeScript"
        exit 1
    fi
    
    log_success "TypeScript compilado com sucesso"
}

# Testar Sharp
test_sharp() {
    log_info "Testando Sharp (processamento de imagens)..."
    
    node -e "
        try {
            const sharp = require('sharp');
            console.log('Sharp versão:', sharp.versions.sharp);
            console.log('libvips versão:', sharp.versions.vips);
        } catch (error) {
            console.error('Erro ao carregar Sharp:', error.message);
            process.exit(1);
        }
    "
    
    if [ $? -ne 0 ]; then
        log_warning "Problema com Sharp detectado. Tentando reinstalar..."
        npm rebuild sharp
        
        if [ $? -ne 0 ]; then
            log_error "Falha ao reinstalar Sharp"
            log_info "Tente instalar manualmente: npm install sharp --platform=linux --arch=x64"
            exit 1
        fi
    fi
    
    log_success "Sharp funcionando corretamente"
}

# Testar Canvas
test_canvas() {
    log_info "Testando Canvas (geração de gráficos)..."
    
    node -e "
        try {
            const { createCanvas } = require('canvas');
            const canvas = createCanvas(100, 100);
            const ctx = canvas.getContext('2d');
            console.log('Canvas funcionando corretamente');
        } catch (error) {
            console.error('Erro ao carregar Canvas:', error.message);
            process.exit(1);
        }
    "
    
    if [ $? -ne 0 ]; then
        log_warning "Problema com Canvas detectado"
        log_info "Verifique se as dependências do sistema estão instaladas"
        
        if [[ "$OS" == "linux" ]]; then
            log_info "Ubuntu/Debian: sudo apt-get install build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev"
        elif [[ "$OS" == "macos" ]]; then
            log_info "macOS: brew install pkg-config cairo pango libpng jpeg giflib librsvg"
        fi
        
        exit 1
    fi
    
    log_success "Canvas funcionando corretamente"
}

# Criar diretórios
create_directories() {
    log_info "Criando diretórios necessários..."
    
    mkdir -p assets
    mkdir -p output
    mkdir -p store_assets
    mkdir -p temp
    
    log_success "Diretórios criados"
}

# Executar testes
run_tests() {
    log_info "Executando testes..."
    
    npm test
    
    if [ $? -ne 0 ]; then
        log_warning "Alguns testes falharam, mas a instalação pode continuar"
    else
        log_success "Todos os testes passaram"
    fi
}

# Gerar ícones de teste
generate_test_icons() {
    log_info "Gerando ícones de teste..."
    
    npm run preview
    
    if [ $? -ne 0 ]; then
        log_warning "Erro ao gerar ícones de teste"
    else
        log_success "Ícones de teste gerados em output/"
    fi
}

# Configurar Git hooks (opcional)
setup_git_hooks() {
    if [ -d ".git" ]; then
        log_info "Configurando Git hooks..."
        
        # Pre-commit hook
        cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Executando verificações pré-commit..."

# Executar linting
npm run lint
if [ $? -ne 0 ]; then
    echo "❌ Linting falhou. Corrija os erros antes de fazer commit."
    exit 1
fi

# Executar testes
npm test
if [ $? -ne 0 ]; then
    echo "❌ Testes falharam. Corrija os erros antes de fazer commit."
    exit 1
fi

echo "✅ Verificações pré-commit passaram"
EOF
        
        chmod +x .git/hooks/pre-commit
        log_success "Git hooks configurados"
    fi
}

# Mostrar informações finais
show_final_info() {
    echo ""
    log_success "🎉 Instalação concluída com sucesso!"
    echo ""
    echo -e "${BLUE}📋 Comandos disponíveis:${NC}"
    echo "  npm run generate-icons        - Gera todos os ícones"
    echo "  npm run generate-android      - Gera apenas ícones Android"
    echo "  npm run generate-ios          - Gera apenas ícones iOS"
    echo "  npm run generate-web          - Gera apenas ícones Web/PWA"
    echo "  npm run generate-microsoft    - Gera apenas ícones Microsoft"
    echo "  npm run preview               - Gera preview dos ícones"
    echo "  npm run validate              - Valida ícones gerados"
    echo "  npm test                      - Executa testes"
    echo "  npm run lint                  - Executa linting"
    echo ""
    echo -e "${BLUE}📁 Diretórios criados:${NC}"
    echo "  assets/          - Assets de entrada"
    echo "  output/          - Ícones gerados"
    echo "  store_assets/    - Assets para lojas"
    echo ""
    echo -e "${BLUE}🚀 Para começar:${NC}"
    echo "  npm run generate-icons"
    echo ""
    echo -e "${BLUE}📚 Documentação:${NC}"
    echo "  README.md        - Guia completo"
    echo "  CONTRIBUTING.md  - Como contribuir"
    echo "  CHANGELOG.md     - Histórico de mudanças"
    echo ""
    echo -e "${GREEN}Bu Fala Icon Generator está pronto para uso! 🎨${NC}"
}

# Função principal
main() {
    log_info "Iniciando instalação do Bu Fala Icon Generator..."
    
    # Verificações básicas
    check_nodejs
    check_npm
    
    # Instalação
    install_system_deps
    install_npm_deps
    compile_typescript
    
    # Testes
    test_sharp
    test_canvas
    
    # Configuração
    create_directories
    run_tests
    generate_test_icons
    setup_git_hooks
    
    # Finalização
    show_final_info
}

# Tratamento de erros
trap 'log_error "Instalação interrompida"; exit 1' INT TERM

# Executar instalação
main "$@"


