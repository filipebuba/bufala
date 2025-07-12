#!/bin/bash

echo "🎨 Bu Fala Icon Generator - Setup"
echo "================================="

# Verificar se Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não encontrado. Por favor, instale Node.js 16+ primeiro."
    exit 1
fi

# Verificar versão do Node.js
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo "❌ Node.js versão 16+ é necessária. Versão atual: $(node -v)"
    exit 1
fi

echo "✅ Node.js $(node -v) encontrado"

# Instalar dependências
echo "📦 Instalando dependências..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar dependências"
    exit 1
fi

# Compilar TypeScript
echo "🔨 Compilando TypeScript..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Erro ao compilar TypeScript"
    exit 1
fi

# Criar diretórios necessários
echo "📁 Criando diretórios..."
mkdir -p assets
mkdir -p output
mkdir -p store_assets

# Verificar se Sharp funciona (dependência nativa)
echo "🔍 Testando Sharp..."
node -e "const sharp = require('sharp'); console.log('Sharp versão:', sharp.versions.sharp);"

if [ $? -ne 0 ]; then
    echo "❌ Erro com Sharp. Tentando reinstalar..."
    npm rebuild sharp
fi

echo ""
echo "✅ Setup concluído com sucesso!"
echo ""
echo "📋 Comandos disponíveis:"
echo "  npm run generate-icons        - Gera todos os ícones"
echo "  npm run generate-android      - Gera apenas ícones Android"
echo "  npm run generate-ios          - Gera apenas ícones iOS"
echo "  npm run generate-web          - Gera apenas ícones Web/PWA"
echo "  npm run generate-microsoft    - Gera apenas ícones Microsoft"
echo "  npm run preview               - Gera preview dos ícones"
echo ""
echo "🚀 Para começar, execute:"
echo "  npm run generate-icons"
echo ""
