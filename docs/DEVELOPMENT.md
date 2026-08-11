# Development Workflow

This project is in infrastructure and research mode. Application code is not part
of Sprint 0.3.

## Branching

- Create a feature branch before changing files.
- Do not commit directly to `main`.
- Do not merge without maintainer approval.
- Keep each branch focused on one sprint or one research area.

Recommended branch names:

```text
sprint-0.3-project-infrastructure
research/display-framebuffer
docs/mqtt-topic-schema
```

## Local Checks

Install development tools in a virtual environment:

```text
python -m venv .venv
.venv\Scripts\python -m pip install --upgrade pip ruff pytest pre-commit
.venv\Scripts\pre-commit install
```

Run checks:

```text
.venv\Scripts\ruff check .
.venv\Scripts\ruff format --check .
.venv\Scripts\pytest --collect-only
```

## Research Rules

- Every technical statement needs a source.
- Unknowns must be listed explicitly.
- Avoid unsourced memory, guesses, and inferred hardware behavior.
- Prefer primary sources, schematics, firmware images, or direct hardware logs.

## No Application Code Yet

Before implementation starts, the project needs:

- Confirmed hardware access
- Confirmed boot and recovery process
- Confirmed display, touch, and audio device paths
- Confirmed Python/runtime constraints
- Reviewed architecture boundaries
