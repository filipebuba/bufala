---
name: moransa-demo-evidence-report
description: Generate a concrete pass/fail technical evidence report for Moransa demo readiness, including environment state, API checks, and explicit blockers.
---

# Moransa Demo Evidence Report

## Overview
Use this skill to produce a technical evidence document before external presentations.

## Workflow
1. Ensure smoke checks were run.
2. Run `scripts/generate-report.sh`.
3. Review `docs/DEMO_READINESS_REPORT.md` and decide presentation readiness.

## Required Sections
- Environment status
- API pass/fail table
- Critical blockers
- Go/No-Go decision

## Resources
- `scripts/generate-report.sh`
- `references/report-template.md`
