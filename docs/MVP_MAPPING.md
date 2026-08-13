# MVP Mapping

Status: Sprint 5 discovery document.

Scope: Map the current MVP, "a Chumby controlled from Home Assistant that wakes Luka with music based on his school schedule," to existing Zurk Offline Firmware capabilities. This document does not define a new API and does not implement Home Assistant integration.

Evidence sources: USB filesystem mounted at `E:\` on 2026-08-13, especially `E:\README.TXT`, `E:\lighty\lighttpd.conf`, `E:\lighty\html\index.html`, `E:\lighty\html\chum.js`, `E:\lighty\cgi-bin\*.sh`, `E:\lighty\cgi-bin\custom\*.sh`, and `E:\lighty\cgi-bin\chumote\*.cgi`. Project architecture source: `docs\ARCHITECTURE.md`.

Runtime warning: Sprint 9 hardware validation shows that the firmware endpoints selected for reuse are not currently reachable because the active HTTP runtime differs from the Sprint 5 extracted-file inventory. Home Assistant reuse remains the target design, but it is blocked until Sprint 10 restores CGI reachability using the measured BusyBox httpd runtime evidence.

## Mapping Summary

| MVP feature | Decision | Existing firmware endpoint or project module | Motivation | Evidence |
| --- | --- | --- | --- | --- |
| Home Assistant decides wake time from Luka's school schedule | Needs custom implementation | Future Home Assistant automation/integration | Zurk firmware exposes device controls, but no inspected endpoint reads Home Assistant calendars or school schedules. | `E:\lighty\cgi-bin`, `E:\lighty\cgi-bin\custom`, `E:\lighty\cgi-bin\chumote`, `docs\ARCHITECTURE.md` |
| Home Assistant triggers wake sequence | Needs custom implementation | Future Home Assistant automation/integration | The firmware exposes HTTP endpoints but does not provide the project-specific Home Assistant orchestration layer. | `E:\lighty\lighttpd.conf`, `docs\ARCHITECTURE.md` |
| Speak a wake phrase | Reuse existing firmware | `/cgi-bin/speak.pl?action=say&words=<text>` | `speak.pl` accepts `action=say` and calls the bundled Flite TTS binary. | `E:\lighty\cgi-bin\speak.pl`, `E:\README.TXT` |
| Speak current time or a scheduled time | Reuse existing firmware | `/cgi-bin/speak.pl` and `/cgi-bin/speak.pl?action=time&time=HH:MM` | `speak.pl` has no-query current-time behavior and an `action=time` branch. | `E:\lighty\cgi-bin\speak.pl` |
| Set wake volume | Reuse existing firmware | `/cgi-bin/custom/setvol.sh?<0-100>` | `setvol.sh` sends a `MusicPlayer setVolume` event with the query string as the value. | `E:\lighty\cgi-bin\custom\setvol.sh`, `E:\lighty\html\index.html` |
| Mute audio | Reuse existing firmware with limitation | `/cgi-bin/custom/setmute.sh` or `/cgi-bin/chumote/event.cgi?setVolume0` | `setmute.sh` sends `setMute on`; Chumote can set volume to zero. No separate unmute script was found. | `E:\lighty\cgi-bin\custom\setmute.sh`, `E:\lighty\cgi-bin\chumote\event.cgi` |
| Play a remote MP3 or stream URL | Reuse existing firmware, hardware validation required | `/cgi-bin/zmote_play.sh?<url>` | `zmote_play.sh` sends a `UserPlayer play` event using the raw query string. Actual codec and stream support must be tested on hardware. | `E:\lighty\cgi-bin\zmote_play.sh`, `E:\lighty\html\index.html` |
| Loop a wake audio file | Reuse existing firmware, hardware validation required | `/cgi-bin/zmote_playloop.sh?<url-or-path>` | `zmote_playloop.sh` sends a `UserPlayer playLoop` event using the raw query string. | `E:\lighty\cgi-bin\zmote_playloop.sh`, `E:\lighty\html\index.html` |
| Play predefined internet radio | Reuse existing firmware | `/cgi-bin/custom/multistreams.sh?<station>`, `/cgi-bin/custom/somafm.sh?<station>`, `/cgi-bin/chumote/streams?<station>` | Existing scripts start hardcoded radio streams or resolve SomaFM playlist URLs. | `E:\lighty\cgi-bin\custom\multistreams.sh`, `E:\lighty\cgi-bin\custom\somafm.sh`, `E:\lighty\cgi-bin\chumote\streams` |
| Stop wake music | Reuse existing firmware | `/cgi-bin/chumote/event.cgi?stopMusic`, `/cgi-bin/custom/multistreams.sh?stop`, `/cgi-bin/chumote/control.cgi?radiostop` | Existing endpoints send `MusicPlayer stop` or run `btplay stop`. | `E:\lighty\cgi-bin\chumote\event.cgi`, `E:\lighty\cgi-bin\custom\multistreams.sh`, `E:\lighty\cgi-bin\chumote\control.cgi` |
| Display a short text notification | Reuse existing firmware with limitation | `/cgi-bin/message.sh?<text>` | `message.sh` writes the query string to `msg.txt`; visible display depends on a widget/profile consuming that file. | `E:\lighty\cgi-bin\message.sh`, `E:\README.TXT` |
| Display HA-Chumby native screens | Needs custom implementation | Future display module | Existing firmware can capture the framebuffer and drive Flash events, but the project requirement for a display engine independent from Home Assistant is not provided by the inspected firmware endpoints. | `E:\lighty\cgi-bin\fb.sh`, `E:\lighty\cgi-bin\fb1.sh`, `docs\ARCHITECTURE.md` |
| Turn screen off | Reuse existing firmware | `/cgi-bin/custom/off.sh` or `/cgi-bin/chumote/event.cgi?off` | `off.sh` writes to `/proc/sys/sense1/dimlevel`; Chumote sends `ScreenManager off`. | `E:\lighty\cgi-bin\custom\off.sh`, `E:\lighty\cgi-bin\chumote\event.cgi` |
| Dim or brighten screen | Reuse existing firmware | `/cgi-bin/custom/dim.sh`, `/cgi-bin/custom/setbrightness.sh?<0-100>`, `/cgi-bin/custom/setday.sh?<0-100>`, `/cgi-bin/custom/setnight.sh?<0-100>`, `/cgi-bin/chumote/event.cgi?dim`, `/cgi-bin/chumote/event.cgi?bright` | Existing scripts expose direct dimlevel writes, brightness preference writes, and ScreenManager events. | `E:\lighty\cgi-bin\custom\dim.sh`, `E:\lighty\cgi-bin\custom\setbrightness.sh`, `E:\lighty\cgi-bin\custom\setday.sh`, `E:\lighty\cgi-bin\custom\setnight.sh`, `E:\lighty\cgi-bin\chumote\event.cgi` |
| Capture current screen for validation | Reuse existing firmware | `/cgi-bin/fb.sh`, `/cgi-bin/fb1.sh`, `/cgi-bin/chumote/fb0`, `/cgi-bin/chumote/fb1` | Existing endpoints return JPEG framebuffer captures. | `E:\lighty\cgi-bin\fb.sh`, `E:\lighty\cgi-bin\fb1.sh`, `E:\lighty\cgi-bin\chumote\fb0`, `E:\lighty\cgi-bin\chumote\fb1` |
| SSH for device diagnostics | Reuse existing firmware with caution | `/cgi-bin/custom/ssh.sh`, `/cgi-bin/custom/sshoff.sh` | Custom Chumote scripts start and stop `/sbin/sshd`; top-level `ssh.sh` says SSH cannot be enabled from that endpoint. | `E:\lighty\cgi-bin\custom\ssh.sh`, `E:\lighty\cgi-bin\custom\sshoff.sh`, `E:\lighty\cgi-bin\ssh.sh`, `E:\README.TXT` |
| MQTT communication | Needs custom implementation | Future MQTT bridge/service | No MQTT broker, client, or MQTT endpoint was found in the inspected Zurk CGI and web files. | `E:\lighty\cgi-bin`, `E:\lighty\cgi-bin\custom`, `E:\lighty\cgi-bin\chumote`, `docs\ARCHITECTURE.md` |
| Offline operation after USB boot | Reuse existing firmware plus project boot scripts | Zurk Offline Firmware and existing HA-Chumby USB overlay | Zurk README says the firmware can operate offline after setup; Sprint 4 boot persistence keeps HA-Chumby control on USB without changing internal flash. | `E:\README.TXT`, `docs\installation\BOOT_PERSISTENCE.md` |

## Recommended MVP Flow

| Step | Recommended action | Reuse decision | Evidence |
| --- | --- | --- | --- |
| 1 | Home Assistant evaluates calendar and school schedule. | Needs custom implementation. | `docs\ARCHITECTURE.md` |
| 2 | Home Assistant sends device commands at the selected wake time. | Needs custom implementation. | `docs\ARCHITECTURE.md` |
| 3 | Set volume with `/cgi-bin/custom/setvol.sh?<0-100>`. | Reuse existing firmware. | `E:\lighty\cgi-bin\custom\setvol.sh` |
| 4 | Wake the screen with `/cgi-bin/chumote/event.cgi?wake` or brighten it with `/cgi-bin/chumote/event.cgi?bright`. | Reuse existing firmware. | `E:\lighty\cgi-bin\chumote\event.cgi` |
| 5 | Speak a short wake phrase with `/cgi-bin/speak.pl?action=say&words=<text>`. | Reuse existing firmware. | `E:\lighty\cgi-bin\speak.pl` |
| 6 | Start music with `/cgi-bin/zmote_play.sh?<url>`. | Reuse existing firmware, hardware validation required. | `E:\lighty\cgi-bin\zmote_play.sh` |
| 7 | Stop music with `/cgi-bin/chumote/event.cgi?stopMusic`. | Reuse existing firmware. | `E:\lighty\cgi-bin\chumote\event.cgi` |

## Needs Custom Implementation

| Area | Reason | Source |
| --- | --- | --- |
| Home Assistant integration | The inspected firmware exposes local HTTP/CGI controls but no Home Assistant integration layer. | `E:\lighty\lighttpd.conf`, `docs\ARCHITECTURE.md` |
| School schedule logic | No inspected firmware file contains calendar or school schedule logic. | `E:\lighty\cgi-bin`, `E:\lighty\cgi-bin\custom`, `E:\lighty\cgi-bin\chumote` |
| MQTT bridge | No MQTT implementation was found in the inspected firmware web and CGI tree. | `E:\lighty\cgi-bin`, `E:\lighty\cgi-bin\custom`, `E:\lighty\cgi-bin\chumote`, `docs\ARCHITECTURE.md` |
| Native display engine | Existing endpoints provide Flash events, message-file updates, and framebuffer capture; they do not provide the planned Home Assistant-independent display engine. | `E:\lighty\cgi-bin\message.sh`, `E:\lighty\cgi-bin\fb.sh`, `docs\ARCHITECTURE.md` |

## Reuse Existing Firmware

| Area | Endpoint family | Source |
| --- | --- | --- |
| TTS | `/cgi-bin/speak.pl` | `E:\lighty\cgi-bin\speak.pl` |
| Media playback | `/cgi-bin/zmote_play.sh`, `/cgi-bin/zmote_playloop.sh`, Chumote `control.cgi?playpodcast&<url>` | `E:\lighty\cgi-bin\zmote_play.sh`, `E:\lighty\cgi-bin\zmote_playloop.sh`, `E:\lighty\cgi-bin\chumote\control.cgi` |
| Stop playback | `/cgi-bin/chumote/event.cgi?stopMusic`, `/cgi-bin/custom/multistreams.sh?stop`, `/cgi-bin/chumote/control.cgi?radiostop` | `E:\lighty\cgi-bin\chumote\event.cgi`, `E:\lighty\cgi-bin\custom\multistreams.sh`, `E:\lighty\cgi-bin\chumote\control.cgi` |
| Volume | `/cgi-bin/custom/setvol.sh`, `/cgi-bin/chumote/event.cgi?setVolume0`, `setVolume50`, `setVolume100` | `E:\lighty\cgi-bin\custom\setvol.sh`, `E:\lighty\cgi-bin\chumote\event.cgi` |
| Brightness and screen control | `/cgi-bin/custom/off.sh`, `/cgi-bin/custom/dim.sh`, `/cgi-bin/custom/setbrightness.sh`, Chumote `event.cgi` screen commands | `E:\lighty\cgi-bin\custom\off.sh`, `E:\lighty\cgi-bin\custom\dim.sh`, `E:\lighty\cgi-bin\custom\setbrightness.sh`, `E:\lighty\cgi-bin\chumote\event.cgi` |
| Diagnostics | `/cgi-bin/top.sh`, `/cgi-bin/dmesg.sh`, `/cgi-bin/logs.sh`, `/cgi-bin/wifi.sh`, `/cgi-bin/fb.sh` | `E:\lighty\cgi-bin\top.sh`, `E:\lighty\cgi-bin\dmesg.sh`, `E:\lighty\cgi-bin\logs.sh`, `E:\lighty\cgi-bin\wifi.sh`, `E:\lighty\cgi-bin\fb.sh` |

## Open Questions

| Question | Why it matters | Source context |
| --- | --- | --- |
| Does `zmote_play.sh` support the exact wake music source planned for Luka, including codec, bitrate, and stream URL type? | The script sends the play event, but the stock player determines actual playback compatibility. | `E:\lighty\cgi-bin\zmote_play.sh` |
| Can `message.sh` be used for visible wake messages without changing the active widget/profile? | The script writes `msg.txt`; visibility depends on the running widget/profile. | `E:\lighty\cgi-bin\message.sh`, `E:\README.TXT` |
| Which screen-control path is most reliable during the persistent boot mode from Sprint 4? | Direct dimlevel writes and Flash ScreenManager events may behave differently when stock UI control is suppressed. | `E:\lighty\cgi-bin\custom\off.sh`, `E:\lighty\cgi-bin\chumote\event.cgi`, `docs\installation\BOOT_PERSISTENCE.md` |
| Can the stock Chumby web server remain available for CGI control while HA-Chumby owns the foreground boot process? | MVP reuse of endpoints depends on the web server being active in the chosen boot mode. | `E:\lighty\lighttpd.conf`, `docs\installation\BOOT_PERSISTENCE.md` |
| What is the safest unmute operation? | A mute-on script exists, but no dedicated unmute script was found in the inspected tree. | `E:\lighty\cgi-bin\custom\setmute.sh`, `E:\lighty\cgi-bin\custom\index.sh` |
