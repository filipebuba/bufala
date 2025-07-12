# Bu Fala Icon Generator - Script de Desenvolvimento (Windows)
# ===========================================================

param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

# Cores
function Write-Info($message) { Write-Host "ℹ️  $message" -ForegroundColor Blue }
function Write-Success($message) { Write-Host "✅ $message" -ForegroundColor Green }
function Write-Warning($message) { Write-Host "⚠️  $message" -ForegroundColor Yellow }
function Write-Error($message) { Write-Host "❌ $message" -ForegroundColor Red }

# Função de ajuda
function Show-Help {
    Write-Host "Bu Fala Icon Generator - Comandos de Desenvolvimento" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Uso: .\dev.ps1 [comando]"
    Write-Host ""
    Write-Host "Comandos disponíveis:"
    Write-Host "  setup           - Configuração inicial do ambiente"
    Write-Host "  dev             - Modo desenvolvimento com watch"
    Write-Host "  build           - Compilar TypeScript"
    Write-Host "  test            - Executar todos os testes"
    Write-Host "  test-watch      - Executar testes em modo watch"
    Write-Host "  test-coverage   - Executar testes com coverage"
    Write-Host "  lint            - Executar linting"
    Write-Host "  lint-fix        - Executar linting e corrigir automaticamente"
    Write-Host "  format          - Formatar código com Prettier"
    Write-Host "  clean           - Limpar arquivos gerados"
    Write-Host "  generate        - Gerar todos os ícones"
    Write-Host "  generate-fast   - Gerar ícones em modo rápido"
    Write-Host "  preview         - Gerar preview dos ícones"
    Write-Host "  validate        - Validar ícones gerados"
    Write-Host "  docs            - Gerar documentação"
    Write-Host "  release         - Preparar release"
    Write-Host "  help            - Mostrar esta ajuda"
    Write-Host ""
}

# Configuração inicial
function Invoke-Setup {
    Write-Info "Configurando ambiente de desenvolvimento..."
    
    npm install
    npm run build
    npm test
    
    $directories = @("assets", "output", "store_assets", "temp")
    foreach ($dir in $directories) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir | Out-Null
        }
    }
    
    Write-Success "Ambiente configurado!"
}

# Modo desenvolvimento
function Start-Dev {
    Write-Info "Iniciando modo desenvolvimento..."
    
    # Iniciar build em watch mode
    Start-Job -ScriptBlock { npm run build -- --watch } -Name "BuildWatch"
    
    # Iniciar testes em watch mode
    Start-Job -ScriptBlock { npm run test:watch } -Name "TestWatch"
    
    Write-Info "Modo desenvolvimento ativo"
    Write-Info "Pressione Ctrl+C para sair"
    
    try {
        # Aguardar interrupção
        while ($true) {
            Start-Sleep -Seconds 1
        }
    }
    finally {
        # Limpar jobs
        Get-Job | Stop-Job
        Get-Job | Remove-Job
    }
}

# Build
function Invoke-Build {
    Write-Info "Compilando TypeScript..."
    npm run build
    Write-Success "Compilação concluída"
}

# Testes
function Invoke-Test {
    Write-Info "Executando testes..."
    npm test
}

function Invoke-TestWatch {
    Write-Info "Executando testes em modo watch..."
    npm run test:watch
}

function Invoke-TestCoverage {
    Write-Info "Executando testes com coverage..."
    npm run test:coverage
    Write-Info "Relatório de coverage disponível em coverage\"
}

# Linting
function Invoke-Lint {
    Write-Info "Executando linting..."
    npm run lint
}

function Invoke-LintFix {
    Write-Info "Executando linting e corrigindo automaticamente..."
    npm run lint -- --fix
    Write-Success "Linting concluído"
}

# Formatação
function Invoke-Format {
    Write-Info "Formatando código..."
    npm run format
    Write-Success "Código formatado"
}

# Limpeza
function Invoke-Clean {
    Write-Info "Limpando arquivos gerados..."
    
    $pathsToClean = @("dist", "output", "store_assets", "temp", "coverage", "node_modules\.cache")
    
    foreach ($path in $pathsToClean) {
        if (Test-Path $path) {
            Remove-Item -Recurse -Force $path
        }
    }
    
    Write-Success "Arquivos limpos"
}

# Geração de ícones
function Invoke-Generate {
    Write-Info "Gerando todos os ícones..."
    npm run generate-icons
    Write-Success "Ícones gerados em store_assets\"
}

function Invoke-GenerateFast {
    Write-Info "Gerando ícones em modo rápido..."
    npm run generate-icons -- --fast
    Write-Success "Ícones gerados rapidamente"
}

# Preview
function Invoke-Preview {
    Write-Info "Gerando preview dos ícones..."
    npm run preview
    Write-Success "Preview gerado em output\"
}

# Validação
function Invoke-Validate {
    Write-Info "Validando ícones gerados..."
    npm run validate
}

# Documentação
function Invoke-Docs {
    Write-Info "Gerando documentação..."
    
    if (Test-Path "jsdoc.json") {
        npx jsdoc -c jsdoc.json
    }
    
    if (Get-Command typedoc -ErrorAction SilentlyContinue) {
        npx typedoc src/
    }
    
    Write-Success "Documentação gerada"
}

# Preparar release
function Invoke-Release {
    Write-Info "Preparando release..."
    
    # Verificar se está na branch main
    $branch = git rev-parse --abbrev-ref HEAD
    if ($branch -ne "main") {
        Write-Error "Release deve ser feito na branch main"
        exit 1
    }
    
    # Verificar se há mudanças não commitadas
    $status = git status --porcelain
    if ($status) {
        Write-Error "Há mudanças não commitadas"
        exit 1
    }
    
    npm test
    npm run lint
    npm run build
    npm run generate-icons
    npm run validate
    
    Write-Success "Release preparado!"
    Write-Info "Execute 'npm version [patch|minor|major]' para criar a versão"
}

# Switch principal
switch ($Command.ToLower()) {
    "setup" { Invoke-Setup }
    "dev" { Start-Dev }
    "build" { Invoke-Build }
    "test" { Invoke-Test }
    "test-watch" { Invoke-TestWatch }
    "test-coverage" { Invoke-TestCoverage }
    "lint" { Invoke-Lint }
    "lint-fix" { Invoke-LintFix }
    "format" { Invoke-Format }
    "clean" { Invoke-Clean }
    "generate" { Invoke-Generate }
    "generate-fast" { Invoke-GenerateFast }
    "preview" { Invoke-Preview }
    "validate" { Invoke-Validate }
    "docs" { Invoke-Docs }
    "release" { Invoke-Release }
    "help" { Show-Help }
    default {
        Write-Error "Comando desconhecido: $Command"
        Show-Help
        exit 1
    }
}

