# Sprint 12 Implementation

Status: Sprint 12 radio preset modernization.

## Goal

Modernize the existing Chumote `radio1` preset without replacing the Zurk playback architecture.

## Implementation Summary

Sprint 12 treats `control.cgi?radio1` as the existing control surface. Hardware validation showed that the endpoint reaches `btplayd` and sends a `playnow` request with the obsolete URL `http://66.162.107.142/cpr1_lo`.

The installer now performs a constrained USB-side patch when the full Zurk file exists:

1. Locate `/lighty/cgi-bin/chumote/control.cgi` on the USB stick.
2. Preserve the original as `/lighty/cgi-bin/chumote/control.cgi.zurk-original`.
3. Replace only `http://66.162.107.142/cpr1_lo` with `https://d3pvma9xb2775h.cloudfront.net/icecast/omropfryslan/radio.mp3`.
4. Leave `radio2`, `radio3`, `btplayd`, lighttpd, and the Chumote routing unchanged.

## Rationale

No separate preset database has been proven yet. Earlier firmware inventory and real hardware output both point to `control.cgi` as the lookup point for `radio1`. Editing `control.cgi` is therefore treated as the smallest currently evidenced exception, and it is limited to a single URL string replacement with a backup.

## Diagnostics

`installer/overlay/ha-chumby/start.sh` now logs radio preset diagnostics to:

```text
/tmp/ha-chumby.log
/mnt/usb/ha-chumby/boot-diagnostics.txt
```

The diagnostics include:

- candidate radio files
- matching lines for `radio1`, `radio2`, `radio3`, `playnow`, `btplay`, `66.162.107.142`, and the Omrop Fryslan URL
- `/psp/url_streams` metadata and contents when present
- whether the patched and original `control.cgi` files exist

## Expected Behavior

After updating the USB stick and rebooting:

```text
GET /cgi-bin/chumote/control.cgi?radio1
```

should produce a `btplayd` request using:

```text
https://d3pvma9xb2775h.cloudfront.net/icecast/omropfryslan/radio.mp3
```

## Rollback

Restore the backed-up USB file:

```powershell
Copy-Item E:\lighty\cgi-bin\chumote\control.cgi.zurk-original E:\lighty\cgi-bin\chumote\control.cgi -Force
```

## Not Changed

Sprint 12 does not:

- modify internal flash
- replace `btplayd`
- replace `control.cgi` routing
- add Home Assistant logic
- add a new playback engine
- change `radio2` or `radio3`

## Hardware Validation

Hardware validation on 2026-08-13 confirmed the URL patch and identified the next failure point. The test command was:

```powershell
Invoke-WebRequest "http://192.168.1.104/cgi-bin/chumote/control.cgi?radio1"
```

Observed output included:

```text
Content-type: text/plain
btplay client v1.4.1.38.50
Connected to btplayd instance 1474
Got response: OK 100 reset
Matched request 100
Got response: OK 101 playnow 0
Matched request 101
playnow * https://d3pvma9xb2775h.cloudfront.net/icecast/omropfryslan/radio.mp3
```

A later repeat after `radiostop` returned HTTP 200 but showed `btplayd` becoming unhealthy:

```text
Connected to btplayd instance 3123
Failed to get response
...killing unresponsive btplayd pid 3123
...waiting for btplayd to die
...attempting start of btplayd
Failed to start btplayd
btplaySignalHandler(13) SIGPIPE - ignoring
Failed to get response
...attempting start of btplayd
Failed to start btplayd
playnow * https://d3pvma9xb2775h.cloudfront.net/icecast/omropfryslan/radio.mp3
```

`/cgi-bin/custom/multistreams.sh?groovesalad` executed and returned `Now playing groovesalad`, but no audio was heard. `/cgi-bin/speak.pl` still produces audible TTS, so the audio hardware and basic output path are working.

Sprint 12 therefore confirms preset modernization and identifies the next failure point as streaming/player playback, not preset lookup.

## Runtime Process Evidence

A `top.sh` capture taken after the local MP3 and stream playback attempts showed the restored stock runtime was active:

| Process or metric | Observed value | Interpretation |
| --- | --- | --- |
| `chumbyflashplay` | PID `2600`, about `77%` CPU, RSS about `18748K` | FlashLite/player runtime is running and busy. |
| `btplayd` | PID `1450`, about `16%` CPU | `btplayd` exists after reboot and is not absent from the runtime. |
| `lighttpd` | PID `2379` | CGI runtime remains available. |
| Memory | about `57080K` used, `4868K` free | Device is memory constrained during playback diagnostics. |
| Load average | `3.73 2.85 1.34` | System is under meaningful load during the failed playback tests. |
| Wi-Fi `rausb0` | IP `192.168.1.104`, RX about `6.6 MiB` | Network is active and receiving data. |

This evidence supports the Sprint 12 conclusion that the services are present, but the player path is not producing audible output for the tested `btplayd`, `UserPlayer` stream, or local MP3 requests.

## Working Stock Radio Evidence

The stock Chumby radio widget did produce audible random radio playback. The lighttpd log captured the working request path:

```text
127.0.0.1 localhost - [13/Aug/2026:21:21:16 +0200] "GET /music.m3u HTTP/1.1" 301 0 "-" "Mozilla/5.0 (compatible; U; Chumby; Linux) Flash Lite 4.0.2"
127.0.0.1 localhost - [13/Aug/2026:21:21:18 +0200] "GET /cgi-bin/randomshuffler.sh HTTP/1.1" 200 1631 "http://localhost:80/music.m3u" "Mozilla/5.0 (compatible; U; Chumby; Linux) Flash Lite 4.0.2"
```

This is the first confirmed audible streaming path. It differs from the failed HTTP control tests:

| Path | Result |
| --- | --- |
| Stock widget `GET /music.m3u` -> `randomshuffler.sh` | Audible stream. |
| `/cgi-bin/chumote/control.cgi?radio1` -> `btplayd` | URL resolves, no audio, can wedge `btplayd`. |
| `/cgi-bin/custom/multistreams.sh?groovesalad` -> `UserPlayer` event | Script executes, no audio. |
| `/cgi-bin/zmote_play.sh?file:///mnt/usb/music/sample.mp3` -> `UserPlayer` event | FlashLite starts, no audio. |

Sprint 13 should inspect `randomshuffler.sh`, `/music.m3u`, and the playlist response that produced audible radio. That working stock path should be preferred over inventing a new playback engine.

## Final Sprint 12 Status

| Area | Status | Evidence |
| --- | --- | --- |
| USB `control.cgi` patch | Confirmed | `radio1` resolves to the Omrop Fryslan URL. |
| Existing Chumote architecture | Preserved | `control.cgi` still calls `btplay`; `btplayd` receives `playnow`. |
| Audible radio playback | Failed | No audio heard after `radio1`. |
| `btplayd` stability | Failed after stream attempt | `btplayd` became unresponsive and failed restart after the patched stream. |
| Flash/UserPlayer stream path | Executes but silent | `multistreams.sh?groovesalad` returned `Now playing groovesalad`, with no audio. |
| Local MP3 through `zmote_play.sh` | Executes but silent | Generated `UserPlayer play` event for `file:///mnt/usb/music/sample.mp3`; FlashLite started, but no audio was heard. |
| Stock radio widget random stream | Confirmed audible | User selected random radio through the Chumby radio widget and heard a stream; logs show `/music.m3u` redirected to `/cgi-bin/randomshuffler.sh`. |
| Runtime process state | Confirmed active | `top.sh` showed `chumbyflashplay`, `btplayd`, and `lighttpd` running. |
| General audio output | Confirmed working | TTS remains audible. |

## Recommended Sprint 13

Create an audio playback diagnostics sprint. Since a local MP3 through `zmote_play.sh` was also silent while the stock radio widget produced audible stream audio, Sprint 13 should inspect `/music.m3u`, `/cgi-bin/randomshuffler.sh`, and the playlist returned to FlashLite, then compare that working path with `btplayd`, `zmote_play.sh`, and `multistreams.sh`. Capture `/tmp/flashplayer.event`, player processes, `btplayd` state, mixer state, selected widget stream URL, and relevant logs after each playback attempt.
