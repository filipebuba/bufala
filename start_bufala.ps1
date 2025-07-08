# Script PowerShell para iniciar o Bu Fala (Backend + Flutter)
# Execute com: powershell -ExecutionPolicy Bypass -File start_bufala.ps1

Write-Host "🌟 Bu Fala - Iniciador Automático" -ForegroundColor Green
Write-Host "=" * 40 -ForegroundColor Green

# Função para verificar se um comando existe
function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Função para verificar se uma porta está em uso
function Test-Port {
    param($Port)
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port $Port -WarningAction SilentlyContinue
        return $connection.TcpTestSucceeded
    } catch {
        return $false
    }
}

# Verificar Python
Write-Host "🐍 Verificando Python..." -ForegroundColor Yellow
if (-not (Test-Command "python")) {
    Write-Host "❌ Python não encontrado. Instale Python 3.8+ primeiro." -ForegroundColor Red
    exit 1
}

$pythonVersion = python --version 2>&1
Write-Host "✅ $pythonVersion encontrado" -ForegroundColor Green

# Verificar Flutter
Write-Host "🎯 Verificando Flutter..." -ForegroundColor Yellow
if (-not (Test-Command "flutter")) {
    Write-Host "❌ Flutter não encontrado. Instale Flutter primeiro." -ForegroundColor Red
    exit 1
}

$flutterVersion = flutter --version | Select-Object -First 1
Write-Host "✅ $flutterVersion encontrado" -ForegroundColor Green

# Verificar se estamos no diretório correto
if (-not (Test-Path "backend\app.py")) {
    Write-Host "❌ Execute este script a partir do diretório raiz do projeto Bu Fala" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Estrutura do projeto encontrada" -ForegroundColor Green

# Verificar se o backend já está rodando
Write-Host "🔍 Verificando se o backend já está rodando..." -ForegroundColor Yellow
if (Test-Port 5000) {
    Write-Host "⚠️ Porta 5000 já está em uso. O backend pode já estar rodando." -ForegroundColor Yellow
    $continue = Read-Host "Deseja continuar mesmo assim? (s/N)"
    if ($continue -notmatch '^[sS]') {
        Write-Host "✅ Operação cancelada" -ForegroundColor Green
        exit 0
    }
}

# Instalar dependências do backend
Write-Host "📦 Instalando dependências do backend..." -ForegroundColor Yellow
Set-Location backend

if (-not (Test-Path "requirements.txt")) {
    Write-Host "⚠️ Criando requirements.txt básico..." -ForegroundColor Yellow
    @"
flask>=2.3.0
flask-cors>=4.0.0
requests>=2.31.0
transformers>=4.35.0
torch>=2.1.0
numpy>=1.24.0
pillow>=10.0.0
speech-recognition>=3.10.0
pyttsx3>=2.90
loguru>=0.7.0
python-dotenv>=1.0.0
"@ | Out-File -FilePath "requirements.txt" -Encoding UTF8
}

try {
    python -m pip install -r requirements.txt
    Write-Host "✅ Dependências do backend instaladas" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao instalar dependências do backend" -ForegroundColor Red
    Set-Location ..
    exit 1
}

# Voltar ao diretório raiz
Set-Location ..

# Instalar dependências do Flutter
Write-Host "📱 Instalando dependências do Flutter..." -ForegroundColor Yellow
Set-Location android_app

try {
    flutter pub get
    Write-Host "✅ Dependências do Flutter instaladas" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao instalar dependências do Flutter" -ForegroundColor Red
    Set-Location ..
    exit 1
}

# Voltar ao diretório raiz
Set-Location ..

# Iniciar backend em background
Write-Host "🚀 Iniciando backend Bu Fala..." -ForegroundColor Yellow
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD\backend
    python app.py
}

# Aguardar o backend iniciar
Write-Host "⏳ Aguardando backend inicializar..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Verificar se o backend está rodando
$backendRunning = $false
for ($i = 0; $i -lt 10; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $backendRunning = $true
            break
        }
    } catch {
        Start-Sleep -Seconds 2
    }
}

if ($backendRunning) {
    Write-Host "✅ Backend iniciado com sucesso em http://localhost:5000" -ForegroundColor Green
} else {
    Write-Host "⚠️ Backend pode não ter iniciado corretamente" -ForegroundColor Yellow
    Write-Host "Verificando logs do backend..." -ForegroundColor Yellow
    
    $jobOutput = Receive-Job -Job $backendJob
    if ($jobOutput) {
        Write-Host "📋 Logs do backend:" -ForegroundColor Cyan
        $jobOutput | ForEach-Object { Write-Host $_ -ForegroundColor White }
    }
}

# Perguntar se deseja iniciar o Flutter
Write-Host ""
Write-Host "📱 Deseja iniciar o aplicativo Flutter agora?" -ForegroundColor Yellow
$startFlutter = Read-Host "(s/N)"

if ($startFlutter -match '^[sS]') {
    Write-Host "🎯 Iniciando aplicativo Flutter..." -ForegroundColor Yellow
    Set-Location android_app
    
    # Verificar dispositivos disponíveis
    Write-Host "📋 Verificando dispositivos disponíveis..." -ForegroundColor Yellow
    flutter devices
    
    Write-Host ""
    Write-Host "🚀 Iniciando Flutter em modo debug..." -ForegroundColor Green
    Write-Host "📱 O aplicativo será aberto no dispositivo/emulador padrão" -ForegroundColor Cyan
    Write-Host "🔧 Para testar a conectividade, use o arquivo test_connection.dart" -ForegroundColor Cyan
    
    try {
        flutter run
    } catch {
        Write-Host "❌ Erro ao iniciar Flutter" -ForegroundColor Red
    }
    
    Set-Location ..
else {
    Write-Host "📱 Para iniciar o Flutter manualmente:" -ForegroundColor Cyan
    Write-Host "   cd android_app" -ForegroundColor White
    Write-Host "   flutter run" -ForegroundColor White
    Write-Host ""
    Write-Host "🔧 Para testar a conectividade:" -ForegroundColor Cyan
    Write-Host "   flutter run lib/test_connection.dart" -ForegroundColor White
}

Write-Host ""
Write-Host "🌐 URLs importantes:" -ForegroundColor Green
Write-Host "   Backend: http://localhost:5000" -ForegroundColor White
Write-Host "   Health Check: http://localhost:5000/health" -ForegroundColor White
Write-Host "   Documentação API: http://localhost:5000/docs" -ForegroundColor White

Write-Host ""
Write-Host "🛑 Para parar o backend, pressione Ctrl+C ou feche esta janela" -ForegroundColor Yellow

# Aguardar input do usuário para manter o script rodando
try {
    Write-Host "⏸️ Pressione Ctrl+C para parar todos os serviços..." -ForegroundColor Cyan
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    Write-Host "🛑 Parando serviços..." -ForegroundColor Yellow
    
    # Parar o job do backend
    if ($backendJob) {
        Stop-Job -Job $backendJob -ErrorAction SilentlyContinue
        Remove-Job -Job $backendJob -ErrorAction SilentlyContinue
    }
    
    Write-Host "✅ Bu Fala finalizado" -ForegroundColor Green
}