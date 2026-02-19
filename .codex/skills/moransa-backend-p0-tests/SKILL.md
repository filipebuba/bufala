---
name: moransa-backend-p0-tests
description: "Use to create and run P0 backend tests for Moransa critical flows: health, medical, education, and agriculture endpoints."
---

# Moransa Backend P0 Tests

## Overview
Use this skill to implement minimal real tests for critical backend flows and keep them passing in every cycle.

## Workflow
1. Run `scripts/scaffold-tests.sh` once to create baseline test file.
2. Run `scripts/run-tests.sh`.
3. Expand assertions incrementally while keeping tests deterministic.

## Test Scope (P0)
- `GET /api/health`
- `POST /api/medical`
- `POST /api/education`
- `POST /api/agriculture`

## Resources
- `scripts/scaffold-tests.sh`
- `scripts/run-tests.sh`
- `references/test-principles.md`
