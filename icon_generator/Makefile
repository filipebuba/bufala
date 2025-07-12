# Bu Fala Icon Generator Makefile

.PHONY: help install build generate integrate full clean preview test

# Variáveis
NODE_VERSION := $(shell node --version 2>/dev/null)
NPM_VERSION := $(shell npm --version 2>/dev/null)
PROJECT_DIR := ../android_app

# Cores para output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Mostrar ajuda
	@echo "$(BLUE)Bu Fala Icon Generator$(NC)"
	@echo "======================"
	@echo ""
	@echo "$(GREEN)Comandos disponíveis:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

check: ## Verificar pré-requisitos
	@echo "$(BLUE)Verificando pré-requisitos...$(NC)"
	@if [ -z "$(NODE_VERSION)" ]; then \
		echo "$(RED)❌ Node.js não encontrado$(NC)"; \
		exit 1; \
	else \
		echo "$(GREEN)✅ Node.js $(NODE_VERSION)$(NC)"; \
	fi
	@if [ -z "$(NPM_VERSION)" ]; then \
		echo "$(RED)❌ npm não encontrado$(NC)"; \
		exit 1; \
	else \
		echo "$(GREEN)✅ npm $(NPM_VERSION)$(NC)"; \
	fi

install: check ## Instalar dependências
	@echo "$(BLUE)Instalando dependências...$(NC)"
	@npm install
	@echo "$(GREEN)✅ Dependências instaladas$(NC)"

build: install ## Compilar TypeScript
	@echo "$(BLUE)Compilando projeto...$(NC)"
	@npm run build
	@echo "$(GREEN)✅ Projeto compilado$(NC)"

generate: build ## Gerar apenas os ícones
	@echo "$(BLUE)Gerando ícones...$(NC)"
	@npm run generate-icons
	@echo "$(GREEN)✅ Ícones gerados$(NC)"

integrate: build ## Integrar com projeto Flutter
	@echo "$(BLUE)Integrando com Flutter...$(NC)"
	@npm run integrate
	@echo "$(GREEN)✅ Integração concluída$(NC)"

full: build ## Gerar ícones e integrar (recomendado)
	@echo "$(BLUE)Executando processo completo...$(NC)"
	@npm run full
	@echo "$(GREEN)✅ Processo completo finalizado$(NC)"
	@echo ""
	@echo "$(YELLOW)Próximos passos:$(NC)"
	@echo "  1. cd $(PROJECT_DIR)"
	@echo "  2. flutter pub get"
	@echo "  3. flutter run"

preview: ## Visualizar ícones disponíveis
	@npm run preview

clean: ## Limpar arquivos gerados
	@echo "$(BLUE)Limpando arquivos...$(NC)"
	@npm run clean
	@rm -rf $(PROJECT_DIR)/assets/icons/
	@rm -f $(PROJECT_DIR)/lib/constants/bufala_icons.dart
	@rm -f $(PROJECT_DIR)/lib/widgets/bufala_icon.dart
	@rm -f $(PROJECT_DIR)/lib/examples/bufala_icon_examples.dart
	@echo "$(GREEN)✅ Limpeza concluída$(NC)"

test: build ## Executar testes
	@echo "$(BLUE)Executando testes...$(NC)"
	@npm test

flutter-setup: ## Configurar projeto Flutter
	@if [ -f "$(PROJECT_DIR)/pubspec.yaml" ]; then \
		echo "$(GREEN)✅ Projeto Flutter encontrado$(NC)"; \
		cd $(PROJECT_DIR) && flutter pub get; \
	else \
		echo "$(RED)❌ Projeto Flutter não encontrado em $(PROJECT_DIR)$(NC)"; \
	fi

dev: ## Modo desenvolvimento (watch)
	@echo "$(BLUE)Iniciando modo desenvolvimento...$(NC)"
	@npm run dev

quick: full flutter-setup ## Geração rápida completa
	@echo "$(GREEN)🎉 Geração rápida concluída!$(NC)"
	@echo "Execute: cd $(PROJECT_DIR) && flutter run"

# Comandos de manutenção
update: ## Atualizar dependências
	@echo "$(BLUE)Atualizando dependências...$(NC)"
	@npm update
	@echo "$(GREEN)✅ Dependências atualizadas$(NC)"

audit: ## Auditoria de segurança
	@echo "$(BLUE)Executando auditoria...$(NC)"
	@npm audit

fix: ## Corrigir vulnerabilidades
	@echo "$(BLUE)Corrigindo vulnerabilidades...$(NC)"
	@npm audit fix

# Comandos de deploy
package: build ## Criar pacote para distribuição
	@echo "$(BLUE)Criando pacote...$(NC)"
	@npm pack
	@echo "$(GREEN)✅ Pacote criado$(NC)"

publish: package ## Publicar no npm (apenas para maintainers)
	@echo "$(BLUE)Publicando no npm...$(NC)"
	@npm publish

# Default target
.DEFAULT_GOAL := help
