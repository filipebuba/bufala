#!/bin/bash

# Bu Fala Icon Generator - Script de Desenvolvimento
# =================================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Função de ajuda
show_help() {
    echo -e "${BLUE}Bu Fala Icon Generator - Comandos de Desenvolvimento${NC}"
    echo ""
    echo "Uso: ./dev.sh [comando]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  setup           - Configuração inicial do ambiente"
    echo "  dev             - Modo desenvolvimento com watch"
    echo "  build           - Compilar TypeScript"
    echo "  test            - Executar todos os testes"
    echo "  test:watch      - Executar testes em modo watch"
    echo "  test:coverage   - Executar testes com coverage"
    echo "  lint            - Executar linting"
    echo "  lint:fix        - Executar linting e corrigir automaticamente"
    echo "  format          - Formatar código com Prettier"
    echo "  clean           - Limpar arquivos gerados"
    echo "  generate        - Gerar todos os ícones"
    echo "  generate:fast   - Gerar ícones em modo rápido"
    echo "  preview         - Gerar preview dos ícones"
    echo "  validate        - Validar ícones gerados"
    echo "  docs            - Gerar documentação"
    echo "  release         - Preparar release"
    echo "  help            - Mostrar esta ajuda"
    echo ""
}

# Configuração inicial
setup() {
    log_info "Configurando ambiente de desenvolvimento..."
    
    # Instalar dependências
    npm install
    
    # Compilar TypeScript
    npm run build
    
    # Executar testes
    npm test
    
    # Criar diretórios
    mkdir -p assets output store_assets temp
    
    log_success "Ambiente configurado!"
}

# Modo desenvolvimento
dev() {
    log_info "Iniciando modo desenvolvimento..."
    
    # Compilar e assistir mudanças
    npm run build -- --watch &
    BUILD_PID=$!
    
    # Executar testes em modo watch
    npm run test:watch &
    TEST_PID=$!
    
    log_info "Modo desenvolvimento ativo"
    log_info "Pressione Ctrl+C para sair"
    
    # Aguardar interrupção
    trap 'kill $BUILD_PID $TEST_PID 2>/dev/null; exit' INT TERM
    wait
}

# Build
build() {
    log_info "Compilando TypeScript..."
    npm run build
    log_success "Compilação concluída"
}

# Testes
test() {
    log_info "Executando testes..."
    npm test
}

test_watch() {
    log_info "Executando testes em modo watch..."
    npm run test:watch
}

test_coverage() {
    log_info "Executando testes com coverage..."
    npm run test:coverage
    log_info "Relatório de coverage disponível em coverage/"
}

# Linting
lint() {
    log_info "Executando linting..."
    npm run lint
}

lint_fix() {
    log_info "Executando linting e corrigindo automaticamente..."
    npm run lint -- --fix
    log_success "Linting concluído"
}

# Formatação
format() {
    log_info "Formatando código..."
    npm run format
    log_success "Código formatado"
}

# Limpeza
clean() {
    log_info "Limpando arquivos gerados..."
    
    rm -rf dist/
    rm -rf output/
    rm -rf store_assets/
    rm -rf temp/
    rm -rf coverage/
    rm -rf node_modules/.cache/
    
    log_success "Arquivos limpos"
}

# Geração de ícones
generate() {
    log_info "Gerando todos os ícones..."
    npm run generate-icons
    log_success "Ícones gerados em store_assets/"
}

generate_fast() {
    log_info "Gerando ícones em modo rápido..."
    npm run generate-icons -- --fast
    log_success "Ícones gerados rapidamente"
}

# Preview
preview() {
    log_info "Gerando preview dos ícones..."
    npm run preview
    log_success "Preview gerado em output/"
}

# Validação
validate() {
    log_info "Validando ícones gerados..."
    npm run validate
}

# Documentação
docs() {
    log_info "Gerando documentação..."
    
    # Gerar JSDoc se configurado
    if [ -f "jsdoc.json" ]; then
        npx jsdoc -c jsdoc.json
    fi
    
    # Gerar README de APIs
    if command -v typedoc &> /dev/null; then
        npx typedoc src/
    fi
    
    log_success "Documentação gerada"
}

# Preparar release
release() {
    log_info "Preparando release..."
    
    # Verificar se está na branch main
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [ "$BRANCH" != "main" ]; then
        log_error "Release deve ser feito na branch main"
        exit 1
    fi
    
    # Verificar se há mudanças não commitadas
    if ! git diff-index --quiet HEAD --; then
        log_error "Há mudanças não commitadas"
        exit 1
    fi
    
    # Executar testes
    npm test
    
    # Executar linting
    npm run lint
    
    # Build
    npm run build
    
    # Gerar ícones
    npm run generate-icons
    
    # Validar
    npm run validate
    
    log_success "Release preparado!"
    log_info "Execute 'npm version [patch|minor|major]' para criar a versão"
}

# Função principal
main() {
    case "${1:-help}" in
        setup)
            setup
            ;;
        dev)
            dev
            ;;
        build)
            build
            ;;
        test)
            test
            ;;
        test:watch)
            test_watch
            ;;
        test:coverage)
            test_coverage
            ;;
        lint)
            lint
            ;;
        lint:fix)
            lint_fix
            ;;
        format)
            format
            ;;
        clean)
            clean
            ;;
        generate)
            generate
            ;;
        generate:fast)
            generate_fast
            ;;
        preview)
            preview
            ;;
        validate)
            validate
            ;;
        docs)
            docs
            ;;
        release)
            release
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Comando desconhecido: $1"
            show_help
            exit 1
            ;;
    esac
}

# Executar
main "$@"
