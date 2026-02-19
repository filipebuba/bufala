# Moransa - Roadmap de 30 Dias para Virar Realidade

## Objetivo
Sair de "protótipo promissor" para "beta funcional e demonstrável" com segurança mínima, execução previsível e evidências técnicas.

## Semana 1 - Estabilização P0
- Remover segredos hardcoded e padronizar variáveis de ambiente.
- Garantir backend sobe sem erro em modo normal e DEMO.
- Garantir imports locais do app Flutter completos (sem arquivos ausentes).
- Corrigir Docker/healthchecks para refletir endpoints reais.
- Entregável: stack sobe, `/api/health` responde, app abre sem falha de import.

## Semana 2 - Fluxos Críticos End-to-End
- Validar fluxo médico básico (pergunta -> resposta).
- Validar fluxo educacional básico.
- Validar fluxo agrícola básico.
- Ajustar contratos de resposta (campos padronizados `success`, `answer`, `error`).
- Entregável: 3 fluxos principais com teste manual documentado.

## Semana 3 - Qualidade e Segurança
- Criar suíte mínima de testes backend (health + 3 fluxos principais).
- Rodar lint e testes no CI.
- Criar checklist de release técnico e funcional.
- Entregável: pipeline simples de qualidade passando.

## Semana 4 - Beta Controlado
- Gerar vídeo de demonstração técnica reproduzível.
- Criar guia de instalação limpa (zero suposições locais).
- Rodar piloto técnico com 3-5 usuários de confiança.
- Entregável: versão beta com feedback real e backlog priorizado.

## Métricas de Sucesso
- Backend inicia em < 60s em ambiente limpo.
- Endpoint `/api/health` estável (sem falha em 20 checks consecutivos).
- Pelo menos 10 testes automatizados backend.
- 0 segredo hardcoded no código executável.
- 3 fluxos principais validados ponta a ponta.
