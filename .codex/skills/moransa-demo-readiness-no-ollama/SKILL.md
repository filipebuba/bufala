---
name: moransa-demo-readiness-no-ollama
description: Validate Moransa demo readiness without Ollama. Start backend-only container, run endpoint smoke tests, and produce a pass/fail checklist for live demos.
---

# Moransa Demo Readiness (No Ollama)

## Overview
Use this skill to validate a reliable demo path when model download is not feasible.

## Workflow
1. Run `scripts/start-backend-only.sh`.
2. Run `scripts/smoke-check.sh`.
3. Read output and decide go/no-go for demo.

## Pass Criteria
- Backend container is `running`.
- `GET /api/health` returns `200`.
- Core API endpoints respond (status not `404`).

## Resources
- `scripts/start-backend-only.sh`
- `scripts/smoke-check.sh`
- `references/demo-checklist.md`
