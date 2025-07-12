# Bu Fala Icon Generator - Instalação Automática (Windows)
# ========================================================

# Configurar política de execução se necessário
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Cores para output
function Write-Info($message) {
    Write-Host "ℹ️  $message" -ForegroundColor Blue
}

function Write-Success($message) {
    Write-Host "✅ $message" -ForegroundColor Green
}

function Write-Warning($message) {
    Write-Host "⚠️  $message" -ForegroundColor Yellow
}

function Write-Error($message) {
    Write-Host "❌ $message" -ForegroundColor Red
}

# Banner
Write-Host @"
 ____        ______    _       
|  _ \      |  ____|  | |      
| |_) |_   _| |__ __ _| | __ _ 
|  _ <| | | |  __/ _` | |/ _` |
| |_) | |_| | | | (_| | | (_| |
|____/ \__,_|_|  \__,_|_|\__,_|

Icon Generator - Instalação Windows
===================================
"@ -ForegroundColor Blue

# Verificar Node.js
function Test-NodeJS {
    Write-Info "Verificando Node.js..."
    
    try {
        $nodeVersion = node --version
        $versionNumber = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
        
        if ($versionNumber -lt 16) {
            Write-Error "Node.js versão 16+ é necessária. Versão atual: $nodeVersion"
            Write-Info "Baixe em: https://nodejs.org/"
            exit 1
        }
        
        Write-Success "Node.js $nodeVersion encontrado"
    }
    catch {
        Write-Error "Node.js não encontrado!"
        Write-Info "Instale Node.js 16+ de: https://nodejs.org/"
        Write-Info "Ou use Chocolatey: choco install nodejs"
        Write-Info "Ou use Winget: winget install OpenJS.NodeJS"
        exit 1
    }
}

# Verificar npm
function Test-NPM {
    Write-Info "Verificando npm..."
    
    try {
        $npmVersion = npm --version
        Write-Success "npm $npmVersion encontrado"
    }
    catch {
        Write-Error "npm não encontrado!"
        exit 1
    }
}

# Verificar Python (necessário para algumas dependências nativas)
function Test-Python {
    Write-Info "Verificando Python..."
    
    try {
        $pythonVersion = python --version 2>$null
        if ($pythonVersion) {
            Write-Success "Python encontrado: $pythonVersion"
        }
        else {
            Write-Warning "Python não encontrado"
            Write-Info "Algumas dependências podem precisar de Python"
            Write-Info "Instale de: https://www.python.org/"
            Write-Info "Ou use: winget install Python.Python.3"
        }
    }
    catch {
        Write-Warning "Python não encontrado - algumas dependências podem falhar"
    }
}

# Verificar Visual Studio Build Tools
function Test-BuildTools {
    Write-Info "Verificando Build Tools..."
    
    $vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    
    if (Test-Path $vsWhere) {
        $buildTools = & $vsWhere -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64
        if ($buildTools) {
            Write-Success "Visual Studio Build Tools encontrado"
        }
        else {
            Write-Warning "Visual Studio Build Tools não encontrado"
            Write-Info "Instale Visual Studio Build Tools para compilar dependências nativas"
            Write-Info "Download: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022"
        }
    }
    else {
        Write-Warning "Visual Studio Build Tools não encontrado"
    }
}

# Instalar dependências npm
function Install-Dependencies {
    Write-Info "Instalando dependências npm..."
    
    # Limpar instalação anterior se existir
    if (Test-Path "node_modules") {
        Write-Info "Limpando instalação anterior..."
        Remove-Item -Recurse -Force "node_modules", "package-lock.json" -ErrorAction SilentlyContinue
    }
    
    # Configurar npm para Windows
    npm config set msvs_version 2022
    npm config set python python
    
    # Instalar dependências
    npm install
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Erro ao instalar dependências npm"
        Write-Info "Tentando com cache limpo..."
        npm cache clean --force
        npm install
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Falha na instalação das dependências"
            Write-Info "Tente instalar manualmente as dependências problemáticas:"
            Write-Info "npm install --build-from-source"
            exit 1
        }
    }
    
    Write-Success "Dependências npm instaladas"
}

# Compilar TypeScript
function Build-TypeScript {
    Write-Info "Compilando TypeScript..."
    
    npm run build
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Erro ao compilar TypeScript"
        exit 1
    }
    
    Write-Success "TypeScript compilado com sucesso"
}

# Testar Sharp
function Test-Sharp {
    Write-Info "Testando Sharp (processamento de imagens)..."
    
    $testScript = @"
try {
    const sharp = require('sharp');
    console.log('Sharp versão:', sharp.versions.sharp);
    console.log('libvips versão:', sharp.versions.vips);
} catch (error) {
    console.error('Erro ao carregar Sharp:', error.message);
    process.exit(1);
}
"@
    
    $testScript | node
    
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Problema com Sharp detectado. Tentando reinstalar..."
        npm rebuild sharp
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Falha ao reinstalar Sharp"
            Write-Info "Tente instalar manualmente:"
            Write-Info "npm uninstall sharp"
            Write-Info "npm install sharp --platform=win32 --arch=x64"
            exit 1
        }
    }
    
    Write-Success "Sharp funcionando corretamente"
}

# Testar Canvas
function Test-Canvas {
    Write-Info "Testando Canvas (geração de gráficos)..."
    
    $testScript = @"
try {
    const { createCanvas } = require('canvas');
    const canvas = createCanvas(100, 100);
    const ctx = canvas.getContext('2d');
    console.log('Canvas funcionando corretamente');
} catch (error) {
    console.error('Erro ao carregar Canvas:', error.message);
    process.exit(1);
}
"@
    
    $testScript | node
    
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Problema com Canvas detectado"
        Write-Info "Canvas pode precisar de dependências adicionais no Windows"
        Write-Info "Tente: npm install canvas --build-from-source"
        exit 1
    }
    
    Write-Success "Canvas funcionando corretamente"
}

# Criar diretórios
function New-Directories {
    Write-Info "Criando diretórios necessários..."
    
    $directories = @("assets", "output", "store_assets", "temp")
    
    foreach ($dir in $directories) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir | Out-Null
        }
    }
    
    Write-Success "Diretórios criados"
}

# Executar testes
function Invoke-Tests {
    Write-Info "Executando testes..."
    
    npm test
    
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Alguns testes falharam, mas a instalação pode continuar"
    }
    else {
        Write-Success "Todos os testes passaram"
    }
}

# Gerar ícones de teste
function New-TestIcons {
    Write-Info "Gerando ícones de teste..."
    
    npm run preview
    
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Erro ao gerar ícones de teste"
    }
    else {
        Write-Success "Ícones de teste gerados em output/"
    }
}

# Mostrar informações finais
function Show-FinalInfo {
    Write-Host ""
    Write-Success "🎉 Instalação concluída com sucesso!"
    Write-Host ""
    Write-Host "📋 Comandos disponíveis:" -ForegroundColor Blue
    Write-Host "  npm run generate-icons        - Gera todos os ícones"
    Write-Host "  npm run generate-android      - Gera apenas ícones Android"
    Write-Host "  npm run generate-ios          - Gera apenas ícones iOS"
    Write-Host "  npm run generate-web          - Gera apenas ícones Web/PWA"
    Write-Host "  npm run generate-microsoft    - Gera apenas ícones Microsoft"
    Write-Host "  npm run preview               - Gera preview dos ícones"
    Write-Host "  npm run validate              - Valida ícones gerados"
    Write-Host "  npm test                      - Executa testes"
    Write-Host "  npm run lint                  - Executa linting"
    Write-Host ""
    Write-Host "📁 Diretórios criados:" -ForegroundColor Blue
    Write-Host "  assets\          - Assets de entrada"
    Write-Host "  output\          - Ícones gerados"
    Write-Host "  store_assets\    - Assets para lojas"
    Write-Host ""
    Write-Host "🚀 Para começar:" -ForegroundColor Blue
    Write-Host "  npm run generate-icons"
    Write-Host ""
    Write-Host "📚 Documentação:" -ForegroundColor Blue
    Write-Host "  README.md        - Guia completo"
    Write-Host "  CONTRIBUTING.md  - Como contribuir"
    Write-Host "  CHANGELOG.md     - Histórico de mudanças"
    Write-Host ""
    Write-Host "Bu Fala Icon Generator está pronto para uso! 🎨" -ForegroundColor Green
}

# Função principal
function Main {
    Write-Info "Iniciando instalação do Bu Fala Icon Generator..."
    
    # Verificações básicas
    Test-NodeJS
    Test-NPM
    Test-Python
    Test-BuildTools
    
    # Instalação
    Install-Dependencies
    Build-TypeScript
    
    # Testes
    Test-Sharp
    Test-Canvas
    
    # Configuração
    New-Directories
    Invoke-Tests
    New-TestIcons
    
    # Finalização
    Show-FinalInfo
}

# Executar instalação
try {
    Main
}
catch {
    Write-Error "Erro durante a instalação: $($_.Exception.Message)"
    exit 1
}
