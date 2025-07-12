@echo off
setlocal enabledelayedexpansion

if "%1"=="" goto help
if "%1"=="help" goto help
if "%1"=="build" goto build
if "%1"=="test" goto test
if "%1"=="generate" goto generate
if "%1"=="preview" goto preview
if "%1"=="clean" goto clean
if "%1"=="lint" goto lint

:help
echo Bu Fala Icon Generator - Comandos de Desenvolvimento
echo.
echo Uso: dev.bat [comando]
echo.
echo Comandos disponiveis:
echo   build     - Compilar TypeScript
echo   test      - Executar testes
echo   generate  - Gerar todos os icones
echo   preview   - Gerar preview dos icones
echo   clean     - Limpar arquivos gerados
echo   lint      - Executar linting
echo   help      - Mostrar esta ajuda
goto end

:build
echo ℹ️  Compilando TypeScript...
npm run build
echo ✅ Compilacao concluida
goto end

:test
echo ℹ️  Executando testes...
npm test
goto end

:generate
echo ℹ️  Gerando todos os icones...
npm run generate-icons
echo ✅ Icones gerados em store_assets\
goto end

:preview
echo ℹ️  Gerando preview dos icones...
npm run preview
echo ✅ Preview gerado em output\
goto end

:clean
echo ℹ️  Limpando arquivos gerados...
if exist "dist" rmdir /s /q "dist"
if exist "output" rmdir /s /q "output"
if exist "store_assets" rmdir /s /q "store_assets"
if exist "temp" rmdir /s /q "temp"
if exist "coverage" rmdir /s /q "coverage"
echo ✅ Arquivos limpos
goto end

:lint
echo ℹ️  Executando linting...
npm run lint
goto end

:end
