@echo off
echo.
echo  ____        ______    _       
echo ^|  _ \      ^|  ____^|  ^| ^|      
echo ^| ^|_^) ^|_   _^| ^|__ __ _^| ^| __ _ 
echo ^|  _ ^<^| ^| ^| ^|  __/ _` ^| ^|/ _` ^|
echo ^| ^|_^) ^| ^|_^| ^| ^| ^| ^(_^| ^| ^| ^(_^| ^|
echo ^|____/ \__,_^|_^|  \__,_^|_^|\__,_^|
echo.
echo Icon Generator - Instalacao Windows
echo ===================================
echo.

REM Verificar Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js nao encontrado!
    echo Instale Node.js 16+ de: https://nodejs.org/
    pause
    exit /b 1
)

echo ✅ Node.js encontrado

REM Verificar npm
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm nao encontrado!
    pause
    exit /b 1
)

echo ✅ npm encontrado

REM Instalar dependências
echo ℹ️  Instalando dependencias...
npm install
if %errorlevel% neq 0 (
    echo ❌ Erro ao instalar dependencias
    pause
    exit /b 1
)

echo ✅ Dependencias instaladas

REM Compilar TypeScript
echo ℹ️  Compilando TypeScript...
npm run build
if %errorlevel% neq 0 (
    echo ❌ Erro ao compilar TypeScript
    pause
    exit /b 1
)

echo ✅ TypeScript compilado

REM Criar diretórios
echo ℹ️  Criando diretorios...
if not exist "assets" mkdir assets
if not exist "output" mkdir output
if not exist "store_assets" mkdir store_assets
if not exist "temp" mkdir temp

echo ✅ Diretorios criados

REM Executar testes
echo ℹ️  Executando testes...
npm test

REM Gerar ícones de teste
echo ℹ️  Gerando icones de teste...
npm run preview

echo.
echo ✅ Instalacao concluida com sucesso!
echo.
echo 📋 Comandos disponiveis:
echo   npm run generate-icons  - Gera todos os icones
echo   npm run preview         - Gera preview dos icones
echo   npm test               - Executa testes
echo.
echo 🚀 Para comecar: npm run generate-icons
echo.
pause
