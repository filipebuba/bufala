---
name: moransa-flutter-readiness
description: Use to prepare Flutter environment for Moransa and run quality checks (`flutter analyze` and `flutter test`) in android_app.
---

# Moransa Flutter Readiness

## Overview
Use this skill to verify Flutter installation and run analyzer/tests for Android app quality gates.

## Workflow
1. Run `scripts/check-flutter.sh`.
2. If Flutter is missing, follow `references/flutter-install.md` and rerun check.
3. Run `scripts/analyze-and-test.sh`.

## Success Criteria
- `flutter --version` works.
- `flutter analyze` exits 0.
- `flutter test` completes.

## Resources
- `scripts/check-flutter.sh`
- `scripts/analyze-and-test.sh`
- `references/flutter-install.md`
