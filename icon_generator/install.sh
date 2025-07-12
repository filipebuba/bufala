#!/bin/bash

echo "🎨 Bu Fala Icon Generator - Instalação"
echo "======================================"

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

# Verificar pré-requisitos
check_prerequisites() {
    log_info "Verificando pré-requisitos..."
    
    # Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js não encontrado. Instale Node.js 16+ primeiro."
        exit 1
    fi
    
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 16 ]; then
        log_error "Node.js versão 16+ necessária. Versão atual: $(node --version)"
        exit 1
    fi
    
    log_success "Node.js $(node --version) ✓"
    
    # npm
    if ! command -v npm &> /dev/null; then
        log_error "npm não encontrado."
        exit 1
    fi
    
    log_success "npm $(npm --version) ✓"
    
    # Flutter (opcional)
    if command -v flutter &> /dev/null; then
        log_success "Flutter $(flutter --version | head -n1 | cut -d' ' -f2) ✓"
    else
        log_warning "Flutter não encontrado (opcional para geração de ícones)"
    fi
}

# Instalar dependências
install_dependencies() {
    log_info "Instalando dependências..."
    
    if [ ! -f "package.json" ]; then
        log_error "package.json não encontrado. Execute este script no diretório icon_generator/"
        exit 1
    fi
    
    # Instalar dependências do sistema (Ubuntu/Debian)
    if command -v apt-get &> /dev/null; then
        log_info "Instalando dependências do sistema (Ubuntu/Debian)..."
        sudo apt-get update
        sudo apt-get install -y build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev
    fi
    
    # Instalar dependências do sistema (macOS)
    if command -v brew &> /dev/null; then
        log_info "Instalando dependências do sistema (macOS)..."
        brew install pkg-config cairo pango libpng jpeg giflib librsvg
    fi
    
    # Instalar dependências npm
    npm install
    
    if [ $? -eq 0 ]; then
        log_success "Dependências instaladas"
    else
        log_error "Erro ao instalar dependências"
        exit 1
    fi
}

# Compilar TypeScript
build_project() {
    log_info "Compilando projeto..."
    
    npm run build
    
    if [ $? -eq 0 ]; then
        log_success "Projeto compilado"
    else
        log_error "Erro na compilação"
        exit 1
    fi
}

# Testar instalação
test_installation() {
    log_info "Testando instalação..."
    
    # Testar comando preview
    npm run preview
    
    if [ $? -eq 0 ]; then
        log_success "Instalação testada com sucesso"
    else
        log_warning "Teste apresentou problemas, mas instalação pode estar funcional"
    fi
}

# Configurar projeto Flutter
setup_flutter_project() {
    log_info "Configurando projeto Flutter..."
    
    FLUTTER_PROJECT="../android_app"
    
    if [ -f "$FLUTTER_PROJECT/pubspec.yaml" ]; then
        log_success "Projeto Flutter encontrado: $FLUTTER_PROJECT"
        
        # Perguntar se deve integrar automaticamente
        read -p "Deseja integrar os ícones automaticamente com o projeto Flutter? (y/n): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Integrando com projeto Flutter..."
            npm run full
            
            if [ $? -eq 0 ]; then
                log_success "Integração concluída"
            else
                log_error "Erro na integração"
            fi
        fi
    else
        log_warning "Projeto Flutter não encontrado em $FLUTTER_PROJECT"
        log_info "Você pode integrar manualmente depois com: npm run integrate"
    fi
}

# Criar atalhos úteis
create_shortcuts() {
    log_info "Criando atalhos úteis..."
    
    # Criar script de geração rápida
    cat > quick-generate.sh << 'EOF'
#!/bin/bash
echo "🚀 Geração rápida de ícones Bu Fala"
npm run full
echo "✅ Concluído! Execute 'cd ../android_app && flutter run' para testar"
EOF
    
    chmod +x quick-generate.sh
    
    # Criar script de limpeza
    cat > clean-all.sh << 'EOF'
#!/bin/bash
echo "🧹 Limpando arquivos gerados..."
npm run clean
rm -rf ../android_app/assets/icons/
rm -rf ../android_app/lib/constants/bufala_icons.dart
rm -rf ../android_app/lib/widgets/bufala_icon.dart
rm -rf ../android_app/lib/examples/bufala_icon_examples.dart
echo "✅ Limpeza concluída"
EOF
    
    chmod +x clean-all.sh
    
    log_success "Atalhos criados: quick-generate.sh, clean-all.sh"
}

# Mostrar informações finais
show_final_info() {
    echo
    echo "🎉 Instalação concluída com sucesso!"
    echo "=================================="
    echo
    echo "📋 Comandos disponíveis:"
    echo "  npm run preview          - Visualizar ícones disponíveis"
    echo "  npm run generate-icons   - Gerar apenas os ícones"
    echo "  npm run integrate        - Integrar com projeto Flutter"
    echo "  npm run full            - Gerar e integrar (recomendado)"
    echo "  ./quick-generate.sh     - Geração rápida"
    echo "  ./clean-all.sh          - Limpar arquivos gerados"
    echo
    echo "🚀 Para começar:"
    echo "  1. ./quick-generate.sh"
    echo "  2. cd ../android_app"
    echo "  3. flutter pub get"
    echo "  4. flutter run"
    echo
    echo "📚 Documentação completa: README.md"
    echo "🐛 Problemas: Verifique o troubleshooting no README.md"
    echo
}

# Função principal
main() {
    echo
    log_info "Iniciando instalação do Bu Fala Icon Generator..."
    echo
    
    check_prerequisites
    echo
    
    install_dependencies
    echo
    
    build_project
    echo
    
    test_installation
    echo
    
    setup_flutter_project
    echo
    
    create_shortcuts
    echo
    
    show_final_info
}

# Executar instalação
main "$@"

