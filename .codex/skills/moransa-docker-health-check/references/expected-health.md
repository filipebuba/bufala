# Expected Backend Health

Endpoint: `GET /api/health`

Expected minimum:
- HTTP 200
- JSON with keys like `success` and `data`

If endpoint is unreachable:
- verify `docker compose ps`
- inspect backend logs
- confirm host port `5000` is free
