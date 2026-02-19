# Release Gates (Moransa)

## P0 - Must pass
- Backend starts without import/runtime crash.
- No hardcoded credentials in repository.
- Health endpoint responds (`/api/health`).
- Docker setup reflects actual project files.
- Mobile app has no missing source files for imports in `lib/`.

## P1 - Should pass before field pilot
- Basic automated tests run in backend and mobile.
- Core flows work end-to-end: medical, education, agriculture.
- Offline fallback behavior is explicit and tested.

## P2 - Production candidate
- CI pipeline with lint + tests + security scan.
- Structured observability (logs, error tracking, uptime checks).
- Deployment guide validated from clean machine.
