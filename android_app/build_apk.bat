@echo off
echo ========================================
echo    BUFALA - Compilacao de APK
echo ========================================
echo.

:: Verificar se Flutter esta instalado
echo Verificando instalacao do Flutter...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Flutter nao encontrado!
    echo Por favor, instale o Flutter primeiro.
    pause
    exit /b 1
)
echo ✓ Flutter encontrado!
echo.

:: Navegar para o diretorio do projeto
cd /d "%~dp0"
echo Diretorio atual: %cd%
echo.

:: Menu de opcoes
:menu
echo Escolha o tipo de APK para compilar:
echo.
echo 1. APK Debug (desenvolvimento - mais rapido)
echo 2. APK Release (producao - otimizado)
echo 3. APK Split por Arquitetura (menor tamanho)
echo 4. Limpar e compilar Release
echo 5. Sair
echo.
set /p choice=Digite sua opcao (1-5): 

if "%choice%"=="1" goto debug
if "%choice%"=="2" goto release
if "%choice%"=="3" goto split
if "%choice%"=="4" goto clean_release
if "%choice%"=="5" goto exit
echo Opcao invalida! Tente novamente.
echo.
goto menu

:debug
echo.
echo [DEBUG] Compilando APK de desenvolvimento...
flutter build apk --debug
goto result

:release
echo.
echo [RELEASE] Compilando APK de producao...
flutter build apk --release
goto result

:split
echo.
echo [SPLIT] Compilando APKs separados por arquitetura...
flutter build apk --split-per-abi
goto result

:clean_release
echo.
echo [CLEAN + RELEASE] Limpando cache e compilando...
flutter clean
flutter pub get
flutter build apk --release
goto result

:result
echo.
if %errorlevel% equ 0 (
    echo ✓ Compilacao concluida com sucesso!
    echo.
    echo APK(s) gerado(s) em:
    echo %cd%\build\app\outputs\flutter-apk\
    echo.
    echo Deseja abrir a pasta dos APKs? (s/n)
    set /p open=
    if /i "%open%"=="s" (
        start "" "%cd%\build\app\outputs\flutter-apk"
    )
) else (
    echo ✗ Erro na compilacao!
    echo Verifique os logs acima para detalhes.
)

echo.
echo Deseja compilar outro APK? (s/n)
set /p again=
if /i "%again%"=="s" goto menu

:exit
echo.
echo Obrigado por usar o Bufala!
pause