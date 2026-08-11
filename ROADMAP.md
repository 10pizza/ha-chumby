# Roadmap

This roadmap favors small milestones with visible outcomes. Each milestone should
leave the project easier for new contributors to understand and run.

## Milestone 0.1: Hardware Access and Development Environment

Goal: make the original Chumby practical to develop against.

Planned work:

- Document Chumby hardware 3.7 assumptions
- Research stock firmware layout and boot behavior
- Document USB boot process
- Establish SSH access
- Identify available Linux userspace tools
- Identify Python availability or installation path
- Confirm framebuffer, touchscreen, and audio device paths
- Create repeatable development workflow

Exit criteria:

- A contributor can boot a known development image or stock firmware path
- A contributor can SSH into the device
- Basic hardware interfaces are documented

## Milestone 0.2: Native Display, Clock, and MQTT

Goal: prove the Chumby can render useful local UI and receive state.

Planned work:

- Choose SDL2 or direct framebuffer path based on hardware tests
- Define display engine interface
- Render clock screen
- Define MQTT connection configuration
- Subscribe to core topics
- Cache last known display state
- Support offline clock display

Exit criteria:

- Chumby displays a native clock without a browser
- MQTT messages can update visible state
- Display code is independent from Home Assistant code

## Milestone 0.3: Home Assistant Integration

Goal: make Home Assistant the control plane.

Planned work:

- Define Home Assistant MQTT discovery strategy
- Publish device availability
- Add event publishing for touchscreen interaction
- Document example automations
- Add weather, calendar, and notification state flows
- Provide installation guidance for Home Assistant users

Exit criteria:

- Home Assistant can send state to the Chumby over MQTT
- The Chumby can publish user interactions back to Home Assistant
- Example automations are documented and reproducible

## Milestone 0.4: Smart Alarm

Goal: provide reliable bedside alarm behavior.

Planned work:

- Define alarm state schema
- Support alarm arm, dismiss, snooze, and next-alarm display
- Add local fallback alarm behavior
- Add touchscreen alarm controls
- Add audio playback for alarm sounds
- Document reliability expectations and limits

Exit criteria:

- Alarm can be controlled by Home Assistant
- Chumby can ring from cached alarm state during temporary network loss
- Dismiss and snooze events round-trip to Home Assistant

## Milestone 0.5: Music Assistant

Goal: integrate with Music Assistant without overloading the Chumby.

Planned work:

- Decide whether Chumby is a controller, player, or both
- Define music topic schema
- Show now-playing state
- Provide playback controls
- Validate audio playback capabilities
- Document supported and unsupported audio formats

Exit criteria:

- Home Assistant or Music Assistant can drive now-playing display
- Touch controls can publish playback events
- Audio strategy is documented

## Milestone 1.0: Full Home Assistant Companion

Goal: deliver a complete, documented, contributor-friendly bedside companion.

Planned work:

- Stable installer
- Stable MQTT and REST schemas
- Complete display engine
- Alarm, weather, calendar, school schedule, notifications, and music screens
- Offline behavior
- Diagnostics tooling
- Contributor documentation
- Release process

Exit criteria:

- A user can install and configure the project from documented steps
- Core bedside features work without custom local patching
- Contributors can add screens or integrations without changing core modules

