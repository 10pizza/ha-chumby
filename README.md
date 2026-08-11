# Home Assistant Chumby Companion

An open-source Home Assistant companion for the original Chumby beanbag device
(hardware 3.7).

The goal is to turn the Chumby into a native bedside Home Assistant device while
respecting the limits and personality of the original hardware. It should feel
like a simple appliance: useful when the network is available, graceful when it
is not, and maintainable enough for contributors to extend.

## Vision

The Chumby is a thin client. Home Assistant is the brain.

Home Assistant owns automation logic, device state, schedules, calendars,
notifications, music routing, and integrations. The Chumby focuses on:

- Rendering a native touchscreen interface
- Playing local audio
- Receiving state and commands
- Reporting local interaction and health
- Continuing basic bedside behavior while offline

The first-class transport is MQTT. REST may be used where it is simpler or more
appropriate, especially for setup, diagnostics, and one-shot data fetches.

## Target Features

- Smart alarm clock
- Weather display
- Calendar display
- School schedule display
- Home Assistant notifications
- Music Assistant integration
- MQTT communication
- REST communication
- Touchscreen interaction
- Audio playback
- Offline operation

## Project Structure

```text
docs/           Architecture notes, decisions, research, and contributor docs
firmware/       Chumby boot, firmware, kernel, USB boot, and SSH research
installer/      Host-side and device-side installation workflow documents
display/        Native display engine design and interface contracts
mqtt/           MQTT topic design, payload schemas, and broker assumptions
homeassistant/  Home Assistant integration design, entities, automations
tools/          Development and diagnostic tooling documentation
assets/         Fonts, icons, sounds, and visual/audio asset documentation
```

No application code is included yet. This repository starts with architecture,
documentation, and development workflow so future implementation work has clear
boundaries.

## Architecture Summary

The companion is split into small modules:

- Display engine: native UI renderer, independent of Home Assistant
- MQTT client: topic subscriptions, publishing, reconnect behavior
- REST client: optional request/response support
- Audio service: alarm sounds, notification tones, future music control
- Input service: touchscreen events mapped to internal actions
- Local state cache: last known clock, alarm, weather, calendar, and settings
- Home Assistant integration: automations, discovery, services, and entities

The display engine consumes normalized local state. It should not know whether
that state came from MQTT, REST, a local cache, or a future test harness.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the full design.

## MQTT Topics

The Chumby should subscribe to these initial topics:

```text
ha/chumby/display
ha/chumby/alarm
ha/chumby/weather
ha/chumby/music
ha/chumby/notification
```

The Chumby should eventually publish local state and interaction events under a
separate command/event namespace, documented in [ARCHITECTURE.md](ARCHITECTURE.md).

## Roadmap

- 0.1: Development environment, firmware research, USB boot, SSH
- 0.2: Native display engine, clock, MQTT
- 0.3: Home Assistant integration
- 0.4: Smart alarm
- 0.5: Music Assistant
- 1.0: Full Home Assistant Companion

See [ROADMAP.md](ROADMAP.md) for details.

## Development Philosophy

- Keep the Chumby client small.
- Prefer documented Linux interfaces.
- Prefer SDL2/framebuffer over a web browser.
- Prefer MQTT for Home Assistant communication.
- Keep modules independently testable.
- Use Python as the primary language.
- Document design decisions before contributors depend on them.

## Current Status

This is the initial architecture and documentation scaffold. Implementation will
begin after the firmware, boot, display, and MQTT assumptions are validated.

