---
name: moransa-docker-health-check
description: Use for Moransa Docker startup validation. Runs docker compose, checks container status, and validates backend health endpoint at /api/health.
---

# Moransa Docker Health Check

## Overview
Use this skill to run the full local stack and confirm backend health before any feature or QA cycle.

## Workflow
1. Run `scripts/run-and-check.sh` from repo root.
2. If health fails, inspect logs with `scripts/debug-logs.sh`.
3. Only proceed when `/api/health` returns success.

## Success Criteria
- `docker compose up -d` completes.
- Backend container is running.
- `http://localhost:5000/api/health` responds with HTTP 200.

## Resources
- `scripts/run-and-check.sh`
- `scripts/debug-logs.sh`
- `references/expected-health.md`
