# Bu Fala - Automação Completa
param(
    [switch]$Full,
    [switch]$Quick,
    [switch]$Deploy
)

function Write-Step($message) {
    Write-Host "🔄 $message" -ForegroundColor Cyan
}

function Write-Done($message) {
    Write-Host "✅ $message" -ForegroundColor Green
}

if ($Full) {
    Write-Step "Iniciando build completo..."
    
    # Limpar tudo
    .\dev.ps1 clean
    
    # Instalar dependências
    npm ci
    
    # Build
    .\dev.ps1 build
    
    # Testes
    .\dev.ps1 test
    
    # Gerar ícones
    .\dev.ps1 generate
    
    # Validar
    npm run validate
    
    # Copiar para Flutter
    if (Test-Path "..\android_app") {
        Copy-Item -Recurse -Force "store_assets\flutter\*" "..\android_app\"
        Copy-Item -Recurse -Force "store_assets\android\*" "..\android_app\android\"
        Copy-Item -Recurse -Force "store_assets\ios\*" "..\android_app\ios\"
        Write-Done "Ícones copiados para Flutter"
    }
    
    Write-Done "Build completo finalizado!"
}

if ($Quick) {
    Write-Step "Build rápido..."
    npm run preview
    Start-Process "output\index.html"
    Write-Done "Preview aberto no navegador"
}

if ($Deploy) {
    Write-Step "Deploy para Flutter..."
    npm run generate-icons
    
    if (Test-Path "..\android_app") {
        Copy-Item -Recurse -Force "store_assets\flutter\*" "..\android_app\"
        Set-Location "..\android_app"
        flutter pub get
        flutter build apk --release
        Write-Done "APK gerado com sucesso!"
    } else {
        Write-Host "❌ Projeto Flutter não encontrado" -ForegroundColor Red
    }
}
