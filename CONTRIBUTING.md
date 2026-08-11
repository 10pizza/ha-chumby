# Contributing

Thanks for helping make the original Chumby useful again.

This project is intentionally modular. Contributors should be able to improve
one area without understanding every firmware, Home Assistant, display, and
audio detail at once.

## Development Workflow

1. Read [ARCHITECTURE.md](ARCHITECTURE.md).
2. Pick a milestone from [ROADMAP.md](ROADMAP.md).
3. Keep changes scoped to one module or documentation area.
4. Document hardware findings as you learn them.
5. Add tests when implementation begins.
6. Open pull requests with a clear summary, test notes, and any hardware used.

## Coding Standards

Python is the primary language.

Future Python code should follow these standards:

- Prefer simple modules over deep inheritance trees
- Keep I/O at module boundaries
- Use typed function signatures where practical
- Keep Home Assistant-specific parsing out of the display engine
- Validate external payloads before updating local state
- Prefer standard library features when they are enough
- Add small tests around message parsing, state updates, and display contracts
- Document hardware-specific assumptions near the code that depends on them

## Architecture Standards

- The Chumby is a thin client
- Home Assistant is authoritative
- MQTT is the preferred transport
- REST is optional and secondary
- Display rendering is independent from Home Assistant
- Offline behavior is explicit and limited
- No module should become the whole application

## Documentation Standards

Documentation should be practical and repeatable.

When documenting hardware or firmware work, include:

- Chumby hardware version
- Firmware version or image source
- Commands used
- Device paths observed
- What worked
- What failed
- Any risk of bricking or data loss

When documenting design decisions, include:

- Decision
- Reason
- Alternatives considered
- Consequences

## Commit and Pull Request Guidance

Use focused commits with clear messages.

Good examples:

```text
docs: describe mqtt topic ownership
installer: document usb boot research notes
display: add clock screen contract
```

Pull requests should include:

- Summary
- Motivation
- Test or verification notes
- Hardware tested, if relevant
- Screenshots or logs, if relevant

## Before Adding Dependencies

The Chumby is constrained hardware. Before adding a dependency, document:

- Why the dependency is needed
- Whether it works on the target Linux environment
- Memory or CPU concerns
- Whether the same job can be done with the standard library

## Contributor-Friendly Boundaries

Expected future contribution areas:

- Firmware and boot research
- Installer workflow
- SDL2/framebuffer rendering
- MQTT schemas and client behavior
- Home Assistant examples and integration
- Audio playback
- Touchscreen input
- Documentation and testing

