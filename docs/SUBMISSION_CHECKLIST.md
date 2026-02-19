# Moransa Submission Checklist

Updated: 2026-02-19

## 1. Backend Demo API
- Status: PASS
- Evidence:
  - `docs/DEMO_READINESS_REPORT.md`
  - `/api/health` -> 200
  - `/api/medical` -> 200
  - `/api/education` -> 200
  - `/api/agriculture` -> 200
  - `/api/translate/contextual` -> 200

## 2. Docker Compose
- Status: PASS (CPU-ready in this environment)
- Evidence:
  - `docker compose up -d` sobe `backend`, `frontend`, `nginx`, `ollama`
  - `docs/ENV_READINESS.md` com daemon e health check OK
- Notes:
  - `docker-compose.yml` foi ajustado para não exigir GPU NVIDIA.
  - `docker-compose.yml` não expõe porta host do Ollama para evitar conflito local de `11434`.

## 3. Flutter Analyze/Test
- Status: BLOCKED (environment DNS/network)
- Current blocker:
  - Flutter CLI não completa bootstrap do Dart SDK por falha de DNS para `storage.googleapis.com`.
- Required to unblock:
  - Disponibilizar internet/DNS para `storage.googleapis.com`, ou
  - Fornecer SDK Flutter + Dart cache offline para instalação local.

## 4. Backend Unit/Integration Tests (pytest)
- Status: BLOCKED in container image
- Current blocker:
  - `pytest` ausente na imagem backend atual (`No module named pytest`).
- Required to unblock:
  - Adicionar dependências de teste na imagem ou rodar pytest em ambiente dev com venv de testes.

## 5. Go/No-Go for External Presentation
- Technical demo backend (API): GO
- Full platform readiness (backend + flutter quality/tests): NO-GO até desbloquear itens 3 e 4
