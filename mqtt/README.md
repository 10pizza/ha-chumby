# MQTT

This directory is for MQTT topic design, payload schemas, and client behavior.

MQTT is the preferred transport between Home Assistant and the Chumby.

Initial subscribed topics:

```text
ha/chumby/display
ha/chumby/alarm
ha/chumby/weather
ha/chumby/music
ha/chumby/notification
```

Initial published topics:

```text
ha/chumby/status
ha/chumby/event
ha/chumby/input
ha/chumby/availability
```

Payloads should be JSON when they carry structured data. Topic schemas should be
versioned before external users depend on them.

