# 🪟 Bu Fala Icon Generator - Guia Windows

## 🚀 Instalação Rápida

### Opção 1: PowerShell (Recomendado)
```powershell
# Abrir PowerShell como Administrador
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Executar instalação
.\install.ps1
```

### Opção 2: Prompt de Comando
```cmd
# Executar instalação
install.bat
```

### Opção 3: Manual
```cmd
# Verificar Node.js
node --version

# Instalar dependências
npm install

# Compilar
npm run build

# Testar
npm test

# Gerar ícones
npm run generate-icons
```

## 🛠️ Pré-requisitos Windows

### Node.js 16+
```powershell
# Opção 1: Download direto
# https://nodejs.org/

# Opção 2: Chocolatey
choco install nodejs

# Opção 3: Winget
winget install OpenJS.NodeJS

# Opção 4: Scoop
scoop install nodejs
```

### Python (Opcional, mas recomendado)
```powershell
# Para compilar dependências nativas
winget install Python.Python.3
```

### Visual Studio Build Tools (Opcional)
```powershell
# Para dependências que precisam compilar código C++
# Download: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
```

## 📋 Comandos Windows

### PowerShell
```powershell
# Desenvolvimento
.\dev.ps1 dev

# Build
.\dev.ps1 build

# Testes
.\dev.ps1 test

# Gerar ícones
.\dev.ps1 generate

# Limpar
.\dev.ps1 clean
```

### Batch
```cmd
# Build
dev.bat build

# Testes
dev.bat test

# Gerar ícones
dev.bat generate

# Preview
dev.bat preview
```

### NPM direto
```cmd
# Gerar todos os ícones
npm run generate-icons

# Gerar apenas Android
npm run generate-android

# Gerar apenas iOS
npm run generate-ios

# Preview
npm run preview

# Validar
npm run validate
```

## 🔧 Solução de Problemas Windows

### Erro: "não é reconhecido como comando"
```powershell
# Verificar se Node.js está no PATH
$env:PATH -split ';' | Where-Object { $_ -like '*node*' }

# Adicionar ao PATH se necessário
$env:PATH += ";C:\Program Files\nodejs"
```

### Erro: "Política de execução"
```powershell
# Permitir execução de scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Erro: "Sharp não funciona"
```cmd
# Reinstalar Sharp para Windows
npm uninstall sharp
npm install sharp --platform=win32 --arch=x64
```

### Erro: "Canvas não compila"
```cmd
# Instalar dependências de build
npm install --global windows-build-tools

# Ou instalar Visual Studio Build Tools manualmente
```

### Erro: "Python não encontrado"
```cmd
# Instalar Python
winget install Python.Python.3

# Configurar npm para usar Python
npm config set python python
```

## 📁 Estrutura de Diretórios Windows

```
bu-fala-icon-generator/
├── assets/              # Assets de entrada
├── dist/               # TypeScript compilado
├── output/             # Preview dos ícones
├── src/                # Código fonte
├── store_assets/       # Ícones finais
│   ├── android/        # Ícones Android
│   ├── ios/           # Ícones iOS
│   ├── web/           # Ícones Web/PWA
│   └── flutter/       # Assets Flutter
├── temp/              # Arquivos temporários
├── install.ps1        # Instalação PowerShell
├── install.bat        # Instalação Batch
├── dev.ps1           # Desenvolvimento PowerShell
└── dev.bat           # Desenvolvimento Batch
```

## 🎯 Integração com Flutter (Windows)

### Copiar ícones gerados
```cmd
# Gerar ícones
npm run generate-icons

# Copiar para projeto Flutter
xcopy /E /I store_assets\flutter\* ..\android_app\
xcopy /E /I store_assets\android\* ..\android_app\android\
xcopy /E /I store_assets\ios\* ..\android_app\ios\
```

### PowerShell para cópia automática
```powershell
# Script para copiar automaticamente
function Copy-IconsToFlutter {
    $flutterPath = "..\android_app"
    
    if (Test-Path $flutterPath) {
        Copy-Item -Recurse -Force "store_assets\flutter\*" "$flutterPath\"
        Copy-Item -Recurse -Force "store_assets\android\*" "$flutterPath\android\"
        Copy-Item -Recurse -Force "store_assets\ios\*" "$flutterPath\ios\"
        
        Write-Host "✅ Ícones copiados para o projeto Flutter"
    } else {
        Write-Host "❌ Projeto Flutter não encontrado em $flutterPath"
    }
}

# Executar
Copy-IconsToFlutter
```

## 🚀 Workflow Completo Windows

### 1. Configuração inicial
```powershell
# Clonar repositório
git clone <repo-url>
cd bu-fala-icon-generator

# Instalar
.\install.ps1
```

### 2. Desenvolvimento
````powershell
# Modo desenvolvimento
.\dev.ps1 dev

# 🪟 Bu Fala Icon Generator - Guia Windows

## 🚀 Instalação Rápida

### Opção 1: PowerShell (Recomendado)
```powershell
# Abrir PowerShell como Administrador
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Executar instalação
.\install.ps1
```

### Opção 2: Prompt de Comando
```cmd
# Executar instalação
install.bat
```

### Opção 3: Manual
```cmd
# Verificar Node.js
node --version

# Instalar dependências
npm install

# Compilar
npm run build

# Testar
npm test

# Gerar ícones
npm run generate-icons
```

## 🛠️ Pré-requisitos Windows

### Node.js 16+
```powershell
# Opção 1: Download direto
# https://nodejs.org/

# Opção 2: Chocolatey
choco install nodejs

# Opção 3: Winget
winget install OpenJS.NodeJS

# Opção 4: Scoop
scoop install nodejs
```

### Python (Opcional, mas recomendado)
```powershell
# Para compilar dependências nativas
winget install Python.Python.3
```

### Visual Studio Build Tools (Opcional)
```powershell
# Para dependências que precisam compilar código C++
# Download: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
```

## 📋 Comandos Windows

### PowerShell
```powershell
# Desenvolvimento
.\dev.ps1 dev

# Build
.\dev.ps1 build

# Testes
.\dev.ps1 test

# Gerar ícones
.\dev.ps1 generate

# Limpar
.\dev.ps1 clean
```

### Batch
```cmd
# Build
dev.bat build

# Testes
dev.bat test

# Gerar ícones
dev.bat generate

# Preview
dev.bat preview
```

### NPM direto
```cmd
# Gerar todos os ícones
npm run generate-icons

# Gerar apenas Android
npm run generate-android

# Gerar apenas iOS
npm run generate-ios

# Preview
npm run preview

# Validar
npm run validate
```

## 🔧 Solução de Problemas Windows

### Erro: "não é reconhecido como comando"
```powershell
# Verificar se Node.js está no PATH
$env:PATH -split ';' | Where-Object { $_ -like '*node*' }

# Adicionar ao PATH se necessário
$env:PATH += ";C:\Program Files\nodejs"
```

### Erro: "Política de execução"
```powershell
# Permitir execução de scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Erro: "Sharp não funciona"
```cmd
# Reinstalar Sharp para Windows
npm uninstall sharp
npm install sharp --platform=win32 --arch=x64
```

### Erro: "Canvas não compila"
```cmd
# Instalar dependências de build
npm install --global windows-build-tools

# Ou instalar Visual Studio Build Tools manualmente
```

### Erro: "Python não encontrado"
```cmd
# Instalar Python
winget install Python.Python.3

# Configurar npm para usar Python
npm config set python python
```

## 📁 Estrutura de Diretórios Windows

```
bu-fala-icon-generator/
├── assets/              # Assets de entrada
├── dist/               # TypeScript compilado
├── output/             # Preview dos ícones
├── src/                # Código fonte
├── store_assets/       # Ícones finais
│   ├── android/        # Ícones Android
│   ├── ios/           # Ícones iOS
│   ├── web/           # Ícones Web/PWA
│   └── flutter/       # Assets Flutter
├── temp/              # Arquivos temporários
├── install.ps1        # Instalação PowerShell
├── install.bat        # Instalação Batch
├── dev.ps1           # Desenvolvimento PowerShell
└── dev.bat           # Desenvolvimento Batch
```

## 🎯 Integração com Flutter (Windows)

### Copiar ícones gerados
```cmd
# Gerar ícones
npm run generate-icons

# Copiar para projeto Flutter
xcopy /E /I store_assets\flutter\* ..\android_app\
xcopy /E /I store_assets\android\* ..\android_app\android\
xcopy /E /I store_assets\ios\* ..\android_app\ios\
```

### PowerShell para cópia automática
```powershell
# Script para copiar automaticamente
function Copy-IconsToFlutter {
    $flutterPath = "..\android_app"
    
    if (Test-Path $flutterPath) {
        Copy-Item -Recurse -Force "store_assets\flutter\*" "$flutterPath\"
        Copy-Item -Recurse -Force "store_assets\android\*" "$flutterPath\android\"
        Copy-Item -Recurse -Force "store_assets\ios\*" "$flutterPath\ios\"
        
        Write-Host "✅ Ícones copiados para o projeto Flutter"
    } else {
        Write-Host "❌ Projeto Flutter não encontrado em $flutterPath"
    }
}

# Executar
Copy-IconsToFlutter
```

## 🚀 Workflow Completo Windows

### 1. Configuração inicial
```powershell
# Clonar repositório
git clone <repo-url>
cd bu-fala-icon-generator

# Instalar
.\install.ps1
```

### 2. Desenvolvimento
````powershell
# Modo desenvolvimento
.\dev.ps1 dev
# Ou comandos individuais
.\dev.ps1 build
.\dev.ps1 test
.\dev.ps1 generate


# Gerar ícones
npm run generate-icons

# Copiar para Flutter
Copy-Item -Recurse -Force "store_assets\flutter\*" "..\android_app\"
Copy-Item -Recurse -Force "store_assets\android\*" "..\android_app\android\"
Copy-Item -Recurse -Force "store_assets\ios\*" "..\android_app\ios\"

# No projeto Flutter
cd ..\android_app
flutter pub get
flutter clean
flutter run

# Editar arquivo de configuração
notepad src\custom-icons.ts

# Adicionar novo ícone
$newIcon = @"
{ name: 'community', icon: '👥', color: '#FF6B35' },
"@

# Regenerar
npm run generate-icons


# Criar script personalizado
$script = @'
# Bu Fala - Script Personalizado
param($Action)

switch ($Action) {
    "full-build" {
        Write-Host "🔄 Build completo iniciado..."
        npm run clean
        npm run build
        npm run generate-icons
        npm run validate
        Write-Host "✅ Build completo concluído!"
    }
    "deploy-flutter" {
        Write-Host "🚀 Deploy para Flutter..."
        npm run generate-icons
        Copy-Item -Recurse -Force "store_assets\flutter\*" "..\android_app\"
        Set-Location "..\android_app"
        flutter pub get
        flutter build apk
        Write-Host "✅ Deploy concluído!"
    }
    "quick-test" {
        Write-Host "⚡ Teste rápido..."
        npm run preview
        Start-Process "output\index.html"
    }
}
'@

$script | Out-File -FilePath "custom.ps1" -Encoding UTF8


# Ativar logs detalhados do npm
set npm_config_loglevel=verbose
npm run generate-icons

# Debug do Node.js
set NODE_DEBUG=*
node dist/index.js


# Monitorar uso de recursos
Get-Process node | Select-Object Name, CPU, WorkingSet

# Monitorar durante geração
$job = Start-Job { npm run generate-icons }
while ($job.State -eq "Running") {
    Get-Process node -ErrorAction SilentlyContinue | 
    Select-Object Name, CPU, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet/1MB,2)}}
    Start-Sleep 2
}


function New-BuildReport {
    $report = @{
        Timestamp = Get-Date
        NodeVersion = node --version
        NpmVersion = npm --version
        Platform = $env:OS
        Architecture = $env:PROCESSOR_ARCHITECTURE
    }
    
    # Executar build e capturar métricas
    $buildStart = Get-Date
    npm run generate-icons 2>&1 | Tee-Object -FilePath "build.log"
    $buildEnd = Get-Date
    
    $report.BuildDuration = ($buildEnd - $buildStart).TotalSeconds
    $report.GeneratedFiles = (Get-ChildItem -Recurse store_assets\).Count
    
    $report | ConvertTo-Json | Out-File "build-report.json"
    Write-Host "📊 Relatório salvo em build-report.json"
}


# Verificar hashes dos ícones gerados
function Test-IconIntegrity {
    $icons = Get-ChildItem -Recurse store_assets\ -Include *.png, *.ico
    
    foreach ($icon in $icons) {
        $hash = Get-FileHash $icon.FullName -Algorithm SHA256
        Write-Host "$($icon.Name): $($hash.Hash.Substring(0,16))..."
    }
}


# Verificar dependências vulneráveis
npm audit

# Corrigir automaticamente
npm audit fix

# Relatório detalhado
npm audit --json | Out-File "security-report.json"


# Limpar cache se houver problemas
npm cache clean --force

# Verificar cache
npm cache verify

# Configurar cache local
npm config set cache "C:\npm-cache"


# Usar múltiplos cores para compilação
$env:UV_THREADPOOL_SIZE = [Environment]::ProcessorCount
npm run build

# Otimizar Sharp para Windows
npm config set sharp_binary_host "https://github.com/lovell/sharp-libvips/releases/download"
npm config set sharp_libvips_binary_host "https://github.com/lovell/sharp-libvips/releases/download"


# Instalar Android Studio
winget install Google.AndroidStudio

# Configurar emulador
cd ..\android_app
flutter emulators --launch Pixel_4_API_30
flutter run


# Servir arquivos web localmente
npx http-server store_assets\web -p 8080 -o

# Ou usar Python
python -m http.server 8080 --directory store_assets\web
