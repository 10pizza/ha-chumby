# Project Infrastructure Review

Review date: 2026-08-11
Branch reviewed: `sprint-0.3-project-infrastructure`
Scope: `pyproject.toml`, `.pre-commit-config.yaml`, GitHub Actions, GitHub issue templates, and `.editorconfig`.

No application code was reviewed or changed.

## Findings

### P3: Pytest configuration exists before CI uses pytest

`pyproject.toml` defines pytest settings at `pyproject.toml:28`, including `testpaths = ["tests"]` at `pyproject.toml:30` and `addopts = "-ra"` at `pyproject.toml:31`. The GitHub Actions workflow installs only Ruff at `.github/workflows/ci.yml:23` and runs only `ruff check .` and `ruff format --check .` at `.github/workflows/ci.yml:26` and `.github/workflows/ci.yml:29`.

This is internally understandable for Sprint 0.3 because the repository is intentionally infrastructure-only and has no application code or tests yet. It should be treated as a parked future decision: once tests are added, CI should install pytest and run it, or the pytest section should remain documented as preparatory configuration.

Severity is low because this does not break current infrastructure checks.

## Overall Consistency

The infrastructure is internally consistent for a documentation-first, no-application-code project.

The project consistently selects Python 3.11 as the host-side development baseline: `pyproject.toml` sets `requires-python = ">=3.11"` at `pyproject.toml:6`, Ruff targets `py311` at `pyproject.toml:22`, and GitHub Actions uses Python `3.11` at `.github/workflows/ci.yml:20`.

Ruff is consistently configured as the only active automated code-quality tool for now. `pyproject.toml` defines Ruff settings, `.pre-commit-config.yaml` runs `ruff` and `ruff-format`, and CI runs `ruff check .` plus `ruff format --check .`. This matches Sprint 0.3 because no Python application package exists yet.

Pre-commit and CI are intentionally not identical. Pre-commit includes local hygiene hooks such as YAML validation, end-of-file fixing, whitespace trimming, merge-conflict checks, and large-file checks. CI currently runs the cross-platform checks most relevant to the repository's future Python tooling. This is an acceptable split, but YAML validation could be added to CI later if GitHub template failures become a concern.

The issue templates are aligned with the current project stage. They separate bug reports, feature requests, and sourced research notes. The research-note template reinforces the repository rule that reverse-engineering claims must be sourced and unknowns must be explicit.

The PR template is consistent with the project workflow. It asks authors to identify whether changes are documentation, infrastructure, research, or application code, and it explicitly reminds contributors that merge approval is required.

The editor configuration is simple and compatible with the current file types. It standardizes UTF-8, LF line endings, final newlines, two-space indentation by default, four-space Python indentation, and preserves Markdown trailing whitespace. That is reasonable for Markdown-heavy infrastructure and future Python code.

## Decision Review

### Python 3.11 baseline

Decision: use Python 3.11 for project tooling and future host-side development configuration.

Reason: it gives modern Python behavior without forcing the old Chumby runtime to support Python 3.11. The Chumby runtime constraints are still unknown and documented separately; this configuration is for repository tooling and future development workflows.

Consequence: contributor tooling can use current Ruff and pytest behavior. Future Chumby-targeted runtime code may need a separate compatibility decision if the device cannot run Python 3.11.

### Ruff as the first automated quality tool

Decision: configure Ruff linting and formatting before application code exists.

Reason: Ruff is fast, simple, and covers import sorting plus common Python lint rules with little project overhead.

Consequence: future Python files will have a clear baseline style. Non-Python documentation remains mostly unaffected.

### Pre-commit for local hygiene

Decision: use pre-commit for local formatting and repository hygiene.

Reason: the project is expected to have contributors, and pre-commit catches low-value churn such as whitespace, missing final newlines, merge conflicts, YAML syntax, and accidentally large files before review.

Consequence: contributors get fast local feedback. CI does not yet enforce every pre-commit hook, so maintainers may choose later whether to add a dedicated pre-commit CI job.

### Lightweight CI

Decision: run only Ruff lint and Ruff format checks in GitHub Actions.

Reason: Sprint 0.3 has no application code and no test suite. Running pytest now would either fail because there are no tests or create noise unrelated to project infrastructure.

Consequence: CI validates the currently meaningful automated checks. Test execution should be added when implementation or test files exist.

### GitHub issue templates

Decision: add separate templates for bugs, feature requests, and research notes.

Reason: this project mixes hardware reverse engineering, Home Assistant integration planning, and future software implementation. Separate templates keep reports actionable.

Consequence: research contributions can be captured without pretending they are bugs or feature requests. Labels referenced by templates may need to be created in GitHub if they do not already exist.

### Pull request template

Decision: add a PR template with scope, verification, hardware-tested, and approval notes.

Reason: the project should avoid accidental application-code changes during research and infrastructure phases, and hardware claims need explicit test context.

Consequence: reviewers get a consistent summary of intent and verification. The template relies on contributor discipline rather than automation.

### EditorConfig

Decision: standardize UTF-8, LF line endings, final newline insertion, trimming, and indentation.

Reason: this reduces cross-platform formatting churn, especially between Windows development machines and Linux CI.

Consequence: Markdown trailing whitespace is preserved because Markdown sometimes uses trailing spaces intentionally for line breaks.

## Follow-Up Recommendations

- Add a CI step for YAML validation if issue-template or workflow syntax becomes a recurring review concern.
- Add pytest to CI when the first tests are introduced.
- Decide on a real open-source license before publishing a release.
- Consider pinning Ruff in CI once releases become reproducible artifacts.
- Create GitHub labels referenced by issue templates: `bug`, `enhancement`, and `research`.
