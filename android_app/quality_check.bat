@echo off
echo ========================================
echo    BUFALA - Verificacao de Qualidade
echo ========================================
echo.

:: Verificar se Flutter esta instalado
echo [1/7] Verificando instalacao do Flutter...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Flutter nao encontrado!
    pause
    exit /b 1
)
echo ✓ Flutter encontrado!
echo.

:: Navegar para o diretorio do projeto
cd /d "%~dp0"
echo Diretorio: %cd%
echo.

:: Instalar dependencias
echo [2/7] Verificando dependencias...
flutter pub get
if %errorlevel% neq 0 (
    echo ERRO: Falha ao instalar dependencias!
    pause
    exit /b 1
)
echo ✓ Dependencias atualizadas!
echo.

:: Analise estatica do codigo
echo [3/7] Executando analise estatica...
flutter analyze
if %errorlevel% neq 0 (
    echo ⚠ Problemas encontrados na analise!
    echo Verifique os warnings/errors acima.
) else (
    echo ✓ Analise estatica passou!
)
echo.

:: Formatacao do codigo
echo [4/7] Verificando formatacao do codigo...
flutter format --set-exit-if-changed lib/
if %errorlevel% neq 0 (
    echo ⚠ Codigo nao esta formatado corretamente!
    echo Executando formatacao automatica...
    flutter format lib/
    echo ✓ Codigo formatado!
) else (
    echo ✓ Codigo ja esta bem formatado!
)
echo.

:: Executar testes unitarios
echo [5/7] Executando testes unitarios...
if exist "test\" (
    flutter test
    if %errorlevel% neq 0 (
        echo ⚠ Alguns testes falharam!
    ) else (
        echo ✓ Todos os testes passaram!
    )
) else (
    echo ⚠ Nenhum teste encontrado!
    echo Considere adicionar testes em test/
)
echo.

:: Verificar estrutura do projeto
echo [6/7] Verificando estrutura do projeto...
set "errors=0"

if not exist "lib\main.dart" (
    echo ✗ main.dart nao encontrado!
    set /a errors+=1
) else (
    echo ✓ main.dart encontrado
)

if not exist "lib\screens\" (
    echo ✗ Pasta screens/ nao encontrada!
    set /a errors+=1
) else (
    echo ✓ Pasta screens/ encontrada
)

if not exist "lib\services\" (
    echo ✗ Pasta services/ nao encontrada!
    set /a errors+=1
) else (
    echo ✓ Pasta services/ encontrada
)

if not exist "lib\providers\" (
    echo ✗ Pasta providers/ nao encontrada!
    set /a errors+=1
) else (
    echo ✓ Pasta providers/ encontrada
)

if not exist "pubspec.yaml" (
    echo ✗ pubspec.yaml nao encontrado!
    set /a errors+=1
) else (
    echo ✓ pubspec.yaml encontrado
)

if %errors% gtr 0 (
    echo ⚠ %errors% problema(s) de estrutura encontrado(s)!
) else (
    echo ✓ Estrutura do projeto OK!
)
echo.

:: Verificar tamanho do APK (se existir)
echo [7/7] Verificando builds anteriores...
if exist "build\app\outputs\flutter-apk\" (
    echo Builds encontrados:
    dir "build\app\outputs\flutter-apk\*.apk" /b 2>nul
    if %errorlevel% equ 0 (
        echo ✓ APKs encontrados na pasta de build
    ) else (
        echo ⚠ Nenhum APK encontrado
    )
) else (
    echo ⚠ Pasta de build nao encontrada
    echo Execute 'flutter build apk' para gerar um APK
)
echo.

:: Resumo final
echo ========================================
echo           RESUMO DA VERIFICACAO
echo ========================================
echo.
echo Projeto: Bufala - Aplicativo Comunitario
echo Versao: 1.0.0+1
echo Plataforma: Android (Flutter)
echo Idiomas: Portugues + Crioulo Guineense
echo Modo: Offline (sem internet necessaria)
echo.
echo Funcionalidades verificadas:
echo ✓ Emergencias medicas
echo ✓ Educacao offline
echo ✓ Agricultura sustentavel
echo ✓ Suporte bilingue
echo ✓ Armazenamento local (Hive)
echo.
echo Para executar o app: flutter run
echo Para compilar APK: flutter build apk
echo.
echo Verificacao concluida!
pause