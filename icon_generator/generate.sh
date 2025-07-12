#!/bin/bash

echo "🎨 Bu Fala Icon Generator"
echo "========================="

# Verificar se Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não encontrado. Instale Node.js primeiro."
    exit 1
fi

# Verificar se npm está instalado
if ! command -v npm &> /dev/null; then
    echo "❌ npm não encontrado. Instale npm primeiro."
    exit 1
fi

# Instalar dependências se necessário
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependências..."
    npm install
fi

# Limpar arquivos anteriores
echo "🧹 Limpando arquivos anteriores..."
npm run clean

# Gerar ícones
echo "🎯 Gerando ícones..."
npm run generate-icons

# Verificar se a geração foi bem-sucedida
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Ícones gerados com sucesso!"
    echo ""
    echo "📁 Arquivos gerados:"
    echo "   - output/: Documentação e configurações"
    echo "   - assets/: Ícones SVG originais"
    echo "   - ../android_app/: Ícones integrados ao projeto Flutter"
    echo ""
    echo "📋 Próximos passos:"
    echo "   1. Verifique os ícones gerados"
    echo "   2. Adicione as configurações do flutter_assets.yaml ao pubspec.yaml"
    echo "   3. Execute 'flutter pub get' no projeto principal"
    echo "   4. Teste a aplicação"
else
    echo "❌ Erro na geração dos ícones"
    exit 1
fi
