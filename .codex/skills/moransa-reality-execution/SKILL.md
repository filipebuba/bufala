---
name: moransa-reality-execution
description: Use when working on Moransa/Bufala to move from prototype to production readiness. Applies to backend, Android, Docker, and docs tasks that require prioritization, stabilization, security hardening, and measurable weekly delivery.
---

# Moransa Reality Execution

## Overview
Use this skill to convert vision into weekly delivery with clear priorities, risk control, and production gates.

## Workflow
1. Baseline
- Run `scripts/reality-check.sh`.
- Record blockers in three buckets: `P0-Broken`, `P1-Unstable`, `P2-Polish`.

2. Execute P0 first
- Fix one critical blocker at a time (security, startup failure, broken imports/routes, invalid Docker).
- After each fix: run the narrowest relevant check and capture evidence.

3. Lock release gates
- Use `references/release-gates.md`.
- Do not claim “ready” if any P0 gate fails.

4. Keep scope realistic
- Prefer small merges that reduce risk immediately.
- Defer non-critical feature expansion until core reliability is stable.

## Default Output Format
When asked for project status, respond with:
- `Current Stage`: Prototype / Stabilizing / Beta / Production candidate.
- `P0 Now`: top 3 blockers.
- `Done This Cycle`: concrete changes with file paths.
- `Next 7 Days`: numbered execution list.

## Resources
- `scripts/reality-check.sh`: quick diagnostics for structure, secrets, missing files, and test baseline.
- `references/release-gates.md`: minimum gates to consider the project serious.
