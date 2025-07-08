@echo off
echo ========================================
echo    BUFALA - Setup e Execucao Automatica
echo ========================================
echo.

:: Verificar se Flutter esta instalado
echo [1/6] Verificando instalacao do Flutter...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Flutter nao encontrado!
    echo Por favor, instale o Flutter primeiro.
    echo Consulte: FLUTTER_SETUP_GUIDE.md
    pause
    exit /b 1
)
echo ✓ Flutter encontrado!
echo.

:: Navegar para o diretorio do projeto
echo [2/6] Navegando para o diretorio do projeto...
cd /d "%~dp0"
echo ✓ Diretorio: %cd%
echo.

:: Limpar cache anterior
echo [3/6] Limpando cache anterior...
flutter clean
echo ✓ Cache limpo!
echo.

:: Instalar dependencias
echo [4/6] Instalando dependencias...
flutter pub get
if %errorlevel% neq 0 (
    echo ERRO: Falha ao instalar dependencias!
    pause
    exit /b 1
)
echo ✓ Dependencias instaladas!
echo.

:: Verificar dispositivos disponiveis
echo [5/6] Verificando dispositivos disponiveis...
flutter devices
echo.

:: Executar o aplicativo
echo [6/6] Executando o aplicativo Bufala...
echo.
echo Pressione 'r' para hot reload
echo Pressione 'R' para hot restart
echo Pressione 'q' para sair
echo.
flutter run

echo.
echo Aplicativo encerrado.
pause