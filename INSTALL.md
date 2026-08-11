# Install

This project is not installable yet. The current repository state is an
architecture and documentation scaffold.

Installation work begins in Milestone 0.1 after the original Chumby hardware and
firmware assumptions are validated.

## Target Install Experience

The eventual installer should support a clear path for users:

1. Prepare a development or install image
2. Boot the Chumby from USB or documented firmware path
3. Enable SSH
4. Configure network
5. Configure MQTT broker credentials
6. Register the device with Home Assistant
7. Start the Chumby companion services
8. Verify display, touch, audio, and MQTT health

## Expected Requirements

Host machine:

- Linux, macOS, or Windows with appropriate USB tooling
- SSH client
- Git
- Python for host-side helper tools

Chumby:

- Original Chumby beanbag, hardware 3.7
- Linux environment
- Network access
- Working display
- Working touchscreen
- Working audio output

Home Assistant:

- MQTT broker configured
- MQTT integration enabled
- Optional Music Assistant integration for later milestones

## Configuration Direction

Future configuration should be stored in a simple local file on the Chumby.

Expected settings:

```text
device_id
display_name
timezone
mqtt.host
mqtt.port
mqtt.username
mqtt.password
display.backend
audio.device
offline.enabled
```

Secrets should be written only to local configuration files and must not be
committed to the repository.

## Current Manual Setup Research Tasks

Before implementation, document:

- How to boot from USB
- How to enable SSH
- How to inspect framebuffer devices
- How to inspect touchscreen input devices
- How to inspect audio devices
- Which Python version is available
- Whether SDL2 can run on the target environment

Research notes should live in `firmware/` or `docs/`.

