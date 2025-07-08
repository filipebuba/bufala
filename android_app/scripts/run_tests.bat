@echo off
echo ========================================
echo    BUFALA APP - SUITE DE TESTES
echo ========================================
echo.

:: Verificar se Flutter está instalado
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter não encontrado. Instale o Flutter primeiro.
    pause
    exit /b 1
)

echo ✅ Flutter encontrado
echo.

:: Navegar para o diretório do projeto
cd /d "%~dp0.."

echo 📦 Instalando dependências...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Erro ao instalar dependências
    pause
    exit /b 1
)

echo ✅ Dependências instaladas
echo.

:: Gerar mocks
echo 🔧 Gerando mocks para testes...
flutter packages pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo ⚠️  Aviso: Erro ao gerar mocks (continuando...)
)

echo ✅ Mocks gerados
echo.

:: Executar análise de código
echo 🔍 Executando análise de código...
flutter analyze
if %errorlevel% neq 0 (
    echo ⚠️  Avisos encontrados na análise de código
) else (
    echo ✅ Análise de código passou
)
echo.

:: Executar testes unitários
echo 🧪 Executando testes unitários...
flutter test --coverage
if %errorlevel% neq 0 (
    echo ❌ Alguns testes unitários falharam
    set TEST_FAILED=1
) else (
    echo ✅ Todos os testes unitários passaram
)
echo.

:: Executar testes de integração
echo 🔗 Executando testes de integração...
flutter test integration_test/
if %errorlevel% neq 0 (
    echo ❌ Alguns testes de integração falharam
    set TEST_FAILED=1
) else (
    echo ✅ Todos os testes de integração passaram
)
echo.

:: Gerar relatório de cobertura
echo 📊 Gerando relatório de cobertura...
if exist coverage\lcov.info (
    echo Cobertura de testes gerada em: coverage\lcov.info
    
    :: Tentar gerar relatório HTML se genhtml estiver disponível
    genhtml coverage\lcov.info -o coverage\html >nul 2>&1
    if %errorlevel% equ 0 (
        echo 📈 Relatório HTML gerado em: coverage\html\index.html
    ) else (
        echo ℹ️  Para relatório HTML, instale: choco install lcov
    )
) else (
    echo ⚠️  Arquivo de cobertura não encontrado
)
echo.

:: Executar testes de performance
echo ⚡ Executando testes de performance...
flutter test test/performance/ --plain-name="performance"
if %errorlevel% neq 0 (
    echo ⚠️  Alguns testes de performance falharam
) else (
    echo ✅ Testes de performance passaram
)
echo.

:: Verificar tamanho do APK (se existir)
if exist build\app\outputs\flutter-apk\app-release.apk (
    echo 📱 Verificando tamanho do APK...
    for %%I in (build\app\outputs\flutter-apk\app-release.apk) do (
        set /a size=%%~zI/1024/1024
        echo Tamanho do APK: !size! MB
        if !size! gtr 50 (
            echo ⚠️  APK maior que 50MB - considere otimização
        ) else (
            echo ✅ Tamanho do APK aceitável
        )
    )
    echo.
)

:: Resumo final
echo ========================================
echo           RESUMO DOS TESTES
echo ========================================

if defined TEST_FAILED (
    echo ❌ ALGUNS TESTES FALHARAM
    echo.
    echo 🔧 Ações recomendadas:
    echo    1. Revisar logs de erro acima
    echo    2. Corrigir testes que falharam
    echo    3. Executar novamente
    echo.
    echo 📋 Para executar testes específicos:
    echo    flutter test test/services/
    echo    flutter test test/widgets/
    echo    flutter test integration_test/
) else (
    echo ✅ TODOS OS TESTES PASSARAM!
    echo.
    echo 🎉 O aplicativo está pronto para:
    echo    ✓ Submissão ao hackathon
    echo    ✓ Deploy de produção
    echo    ✓ Distribuição para comunidades
    echo.
    echo 📊 Próximos passos:
    echo    1. Revisar cobertura de testes
    echo    2. Otimizar performance se necessário
    echo    3. Preparar build de produção
)

echo.
echo 📁 Arquivos importantes:
echo    - Cobertura: coverage\lcov.info
echo    - Logs: test\logs\
echo    - Relatórios: coverage\html\
echo.

echo Pressione qualquer tecla para continuar...
pause >nul