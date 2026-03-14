# Plano de Melhorias do Projeto Moransa

## Objetivo
Elevar a confiabilidade, consistência e capacidade de evolução do projeto, mantendo a proposta de IA comunitária offline como prioridade.

## Princípios
- Segurança e confiabilidade antes de novas funcionalidades.
- Documentação alinhada com o código real.
- Entregas incrementais com validação contínua.
- Melhorias que reduzam risco operacional e facilitem contribuição.

## Onda 1 — Estabilização (P0)

### 1) Corrigir cadeia de release Android
- Remover assinatura de release com chave de debug.
- Configurar assinatura de release via variáveis seguras.
- Critério de aceite: build release gera artefato assinado com keystore de produção.

### 2) Eliminar falso positivo no CI
- Remover `|| true` dos checks críticos.
- Executar testes mínimos reais no backend no pipeline.
- Critério de aceite: falha de teste quebra o workflow.

### 3) Endurecer smoke tests de API
- Ajustar testes P0 para não aceitar HTTP 500 como sucesso.
- Critério de aceite: endpoints críticos retornam 200 em ambiente de teste.

## Onda 2 — Consistência Técnica (P1)

### 4) Alinhar documentação com implementação
- Corrigir referências incorretas de stack (FastAPI/Node/React Native).
- Atualizar instruções de setup para refletir Flutter + Flask + Docker.
- Critério de aceite: documentação principal e do app sem divergências técnicas.

### 5) Endurecer configuração de produção
- Restringir CORS por ambiente.
- Melhorar tratamento de falha na inicialização de serviços críticos.
- Critério de aceite: produção não sobe com configuração insegura.

### 6) Melhorar base de testes Flutter
- Substituir testes placeholder por cenários de serviço e fluxo principal.
- Critério de aceite: redução significativa de testes triviais e aumento de cobertura útil.

## Onda 3 — Escala e Evolução (P2)

### 7) Governança de qualidade
- Unificar configuração de pytest/coverage para evitar drift.
- Limpar `.gitignore` e padronizar higiene de repositório.
- Critério de aceite: configuração única de testes e repositório sem artefatos inválidos.

### 8) Observabilidade e operação
- Definir healthchecks funcionais e checklist de diagnóstico.
- Consolidar métricas básicas de disponibilidade de backend e IA.
- Critério de aceite: troubleshooting reproduzível e rápido.

## Backlog Priorizado
- P0: release Android, CI sem falso verde, smoke tests de API.
- P1: documentação alinhada, CORS e startup hardening, testes Flutter úteis.
- P2: governança de qualidade, observabilidade operacional.

## Resultado Esperado
- Menor risco de produção.
- Maior confiança em deploy e manutenção.
- Base técnica mais clara para contribuições futuras.
