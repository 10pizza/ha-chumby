# Display

This directory is for the native display engine design.

The display engine must be independent from Home Assistant. It should render
normalized local state and expose clear interfaces for screens, themes, and
input regions.

Preferred rendering path:

1. SDL2
2. Linux framebuffer fallback

Initial screens:

- Clock
- Weather
- Calendar
- School schedule
- Notification
- Alarm
- Music

No display application code exists yet.

