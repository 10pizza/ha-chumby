# Architecture

## Core Principle

The Chumby is a thin client. Home Assistant is the brain.

The Chumby should not duplicate Home Assistant automation logic. It should render
state, play audio, collect local input, and publish interaction events. Home
Assistant should decide what the state means and what should happen next.

## Non-Goals for the Initial Architecture

- No monolithic Chumby application
- No browser-based UI as the default runtime
- No direct dependency between display rendering and Home Assistant APIs
- No application code before hardware and firmware assumptions are documented

## Runtime Model

The future Chumby runtime should be composed of small services:

```text
                 Home Assistant
                       |
                       | MQTT preferred
                       | REST optional
                       |
+----------------------+----------------------+
|                  Chumby                      |
|                                             |
|  mqtt client  -> local state cache -> display engine
|       |                 |              |
|       |                 |              +-> SDL2/framebuffer
|       |                 |
|       |                 +-----------> audio service
|       |
|       +<-------------- input service
|                       touchscreen
+---------------------------------------------+
```

## Module Boundaries

### Display Engine

Responsibility:

- Render native UI screens
- Handle layout for the Chumby display
- Consume normalized local state
- Expose display intents such as `show_clock`, `show_weather`, or
  `show_notification`

Design decision:

The display engine must be independent from Home Assistant. It should not import
Home Assistant integration code, call Home Assistant APIs, or parse Home
Assistant-specific payloads directly.

Preferred technology:

- SDL2 first if available and performant
- Linux framebuffer fallback if SDL2 is impractical
- No web browser requirement

### MQTT Client

Responsibility:

- Connect to broker
- Subscribe to command/state topics
- Publish availability, health, and input events
- Normalize incoming payloads before updating local state
- Handle reconnects and retained messages

Initial subscribed topics:

```text
ha/chumby/display
ha/chumby/alarm
ha/chumby/weather
ha/chumby/music
ha/chumby/notification
```

Proposed published topics:

```text
ha/chumby/status
ha/chumby/event
ha/chumby/input
ha/chumby/availability
```

Topic design decisions:

- Incoming topics are state or commands from Home Assistant to Chumby
- Published topics are observations or events from Chumby to Home Assistant
- Payloads should be JSON where structured data is needed
- Retained messages are appropriate for display, weather, alarm, and music state
- Short-lived notifications may be retained or non-retained depending on UX

### REST Client

Responsibility:

- Support setup and diagnostics where request/response is simpler than MQTT
- Fetch optional resources that are awkward to send through MQTT
- Remain optional for core bedside operation

Design decision:

REST is a secondary transport. MQTT should be enough for normal operation.

### Audio Service

Responsibility:

- Play alarm sounds
- Play notification sounds
- Report audio capability
- Later support Music Assistant playback or control

Design decision:

Audio should be abstracted behind a simple interface because the final playback
stack may depend on what the original Chumby Linux environment supports.

### Input Service

Responsibility:

- Read touchscreen events
- Convert raw input into normalized interactions
- Publish user actions through the event layer

Examples:

```text
tap.dismiss_alarm
tap.snooze_alarm
tap.next_screen
tap.music_play_pause
```

### Local State Cache

Responsibility:

- Store last known useful state
- Allow display rendering while offline
- Allow local fallback alarm behavior
- Provide one state interface to the display engine

Design decision:

The state cache is the internal contract between transports and UI. The display
engine should render from this cache, not from raw MQTT messages.

### Home Assistant Integration

Responsibility:

- Provide MQTT discovery where appropriate
- Publish state to Chumby topics
- Consume Chumby availability and input events
- Provide example automations and blueprints in the future

Design decision:

The Home Assistant side should be optional and understandable. Users should be
able to start with documented MQTT topics before installing a custom integration.

## Data Flow

### Display Update

1. Home Assistant publishes a JSON payload to `ha/chumby/display`.
2. MQTT client receives the payload.
3. Payload is validated and normalized.
4. Local state cache is updated.
5. Display engine renders the selected screen.

### Touch Interaction

1. User taps the Chumby touchscreen.
2. Input service converts raw coordinates into an action.
3. Chumby publishes an event to `ha/chumby/event` or `ha/chumby/input`.
4. Home Assistant automation reacts to the event.
5. Home Assistant publishes any resulting state changes back to Chumby.

### Offline Operation

Offline behavior should be explicit and limited:

- Continue showing local time if the device clock is valid
- Continue showing cached alarm state
- Ring a cached alarm when possible
- Show stale weather/calendar/schedule state with a visible stale indicator
- Queue non-critical local events only if reliable storage is available

Home Assistant remains authoritative when connectivity returns.

## Configuration

Future configuration should be file-based and simple.

Expected configuration categories:

- MQTT broker host, port, username, password
- Device ID and display name
- Timezone
- Audio device
- Display backend
- Offline behavior options

Secrets should not be committed to the repository.

## Python Direction

Python is the primary project language because it is readable, contributor
friendly, and appropriate for small Linux device services.

Expected future package boundaries:

- `display`
- `mqtt`
- `audio`
- `input`
- `state`
- `homeassistant`
- `installer`

The exact package layout should be decided after Milestone 0.1 confirms the
available Python version and dependency constraints on the Chumby.

## Design Decisions

### Chumby as Thin Client

Decision: keep automation and integration logic in Home Assistant.

Reason: Home Assistant already has calendar, weather, school schedule,
notification, and music integrations. Duplicating that logic on old hardware
would make the project fragile.

### MQTT as Preferred Transport

Decision: use MQTT for normal state, commands, availability, and events.

Reason: MQTT is already a Home Assistant-native pattern, works well for retained
state, tolerates reconnects, and keeps the Chumby client simple.

### Display Independent from Home Assistant

Decision: the display engine renders normalized state and knows nothing about
Home Assistant internals.

Reason: this makes the UI testable, portable, and easier to evolve. It also lets
contributors work on display behavior without needing a Home Assistant instance.

### SDL2/Framebuffer over Browser

Decision: prefer SDL2 or direct framebuffer rendering.

Reason: the original Chumby is constrained hardware. A browser runtime would add
memory, CPU, packaging, and maintenance costs that do not fit the device.

### No Application Code Yet

Decision: start with documentation and structure only.

Reason: the hardware and firmware assumptions must be validated before the code
architecture hardens around the wrong constraints.

