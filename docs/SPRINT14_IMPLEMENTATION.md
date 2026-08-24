# Sprint 14 Implementation

Status: diagnostics and documentation prepared. Hardware snapshot capture is required before a proof-of-concept can be written.

## Goal

Discover the original trigger used when the stock Music Player starts the known-good `Random music` playback path.

## Implementation Summary

Sprint 14 makes investigation-focused changes only:

- preserves the stock music player configuration during USB preparation
- avoids boot-time stock music trigger probing after hardware showed it could prevent or delay the Zork interface
- adds a manual snapshot helper for before/after Play-button comparisons
- documents the evidence model and hardware test procedure

No Home Assistant integration, player replacement, FlashLite modification, `btplayd` modification, or stock UI modification was added.

## Installer Correction

Sprint 13 temporarily modified `/psp/url_streams` and `control.cgi` for experiments with modern radio URLs. Hardware testing showed those paths did not produce reliable audio.

Sprint 14 therefore stops applying those experimental changes in `installer/prepare_usb.ps1`.

The installer now preserves the stock `Random music` configuration so the only proven playback path remains available for investigation:

```text
/psp/url_streams -> http://localhost/music.m3u
```

This is a documentation-backed rollback of a failed experiment, not a new playback implementation.

## Added Files

| File | Purpose |
| --- | --- |
| `installer/overlay/ha-chumby/music-player-snapshot.sh` | Capture stock music player runtime state before and after pressing Play. |
| `docs/STOCK_MUSIC_PLAYER_CONTROL.md` | Sprint 14 knowledge base and test procedure. |
| `docs/SPRINT14_IMPLEMENTATION.md` | Implementation summary and validation instructions. |

## Modified Files

| File | Change |
| --- | --- |
| `installer/overlay/ha-chumby/start.sh` | Restored to avoid automatic stock music trigger probing during boot. |
| `installer/prepare_usb.ps1` | Preserves stock stream/radio configuration and verifies the snapshot helper is copied. |

## Diagnostics Added

Sprint 14 originally added automatic boot-time stock music trigger diagnostics. Hardware feedback showed the Zork interface did not load reliably afterward, so those automatic probes were removed.

The only Sprint 14 trigger diagnostic is now the manual snapshot helper. It should be run after the stock UI and Zork interface are already working.

## Manual Snapshot Helper

The snapshot helper is copied to the USB as:

```text
/mnt/usb/ha-chumby/music-player-snapshot.sh
```

Example use over SSH:

```sh
sh /mnt/usb/ha-chumby/music-player-snapshot.sh before-play
sh /mnt/usb/ha-chumby/music-player-snapshot.sh after-play-0s
sh /mnt/usb/ha-chumby/music-player-snapshot.sh playing
sh /mnt/usb/ha-chumby/music-player-snapshot.sh after-stop
```

Each run writes a persistent USB-side file:

```text
/mnt/usb/ha-chumby/music-player-<label>.txt
```

## Snapshot Stability Finding

Hardware feedback showed the first manual Sprint 14 snapshot made the Chumby stop responding. The original helper was too heavy for the device while FlashLite was running because it scanned `/proc`, listed file descriptors, dumped sockets, searched large filesystem trees, and fetched `/music.m3u`.

The snapshot helper has been reduced to a lightweight capture only:

- timestamp
- uptime
- memory
- `ps`
- selected state files
- selected `/tmp` candidate filenames
- recent lighttpd access/error log lines

Do not run the older full snapshot helper on hardware.
## Snapshot Comparison Findings

Hardware snapshots from 2026-08-14 captured the stock Music Player transition from idle to playing.

| Snapshot | Time | Key observation |
| --- | --- | --- |
| `before-play` | 14:06:15 | `btplayd` PID `1434` was running, `/psp/url_streams` pointed to `http://localhost/music.m3u`, no `/tmp/musicsource` was present. |
| `selected` | 14:07:36 | Selecting `Random music` did not create `/tmp/musicsource`; `btplayd` remained PID `1434`. |
| `after-play` | 14:08:26 | `/tmp/musicsource` appeared with timestamp `14:08`; `btplayd` remained PID `1434` but RSS increased from about `1332K` to `2548K`; `chumbyflashplayer.x` became runnable; lighttpd logged `GET /music.m3u` and `GET /cgi-bin/randomshuffler.sh`. |
| `playing` | 14:09:22 | `/tmp/musicsource` persisted; `btplayd` remained PID `1434`; the same FlashLite-originated `/music.m3u` and `randomshuffler.sh` log lines remained the audio evidence. |

Observed access log lines from the `after-play` and `playing` snapshots:

```text
127.0.0.1 localhost - [14/Aug/2026:14:08:24 +0200] "GET /music.m3u HTTP/1.1" 301 0 "-" "Mozilla/5.0 (compatible; U; Chumby; Linux) Flash Lite 4.0.2"
127.0.0.1 localhost - [14/Aug/2026:14:08:25 +0200] "GET /cgi-bin/randomshuffler.sh HTTP/1.1" 200 222 "http://localhost:80/music.m3u" "Mozilla/5.0 (compatible; U; Chumby; Linux) Flash Lite 4.0.2"
```

Interpretation from evidence:

- Pressing the touchscreen Play button is the first observed action that creates `/tmp/musicsource`.
- FlashLite, not a desktop browser and not the snapshot script, requests `/music.m3u`.
- `randomshuffler.sh` is invoked by lighttpd in response to FlashLite following the `/music.m3u` redirect.
- `randomshuffler.sh` only returns playlist text; it does not start playback itself.
- `btplayd` owns a stable process throughout the transition and appears to enter playback state without being restarted.
- No `/tmp/flashplayer.event` was captured, so the stock Play button is not proven to use the simple event-file trigger used by some CGI scripts.

The next evidence target is the content of `/tmp/musicsource`, because its creation is the clearest newly observed state transition after pressing Play.
## Musicsource Content Finding

A follow-up hardware snapshot captured `/tmp/musicsource` while the stock `Random music` path was active.

Observed file:

```xml
<musicSource state="&lt;stream url=&quot;http://localhost/music.m3u&quot; id=&quot;&quot; mimetype=&quot;audio/x-mpegurl&quot; name=&quot;Random music&quot; /&gt;" label="Random music" selector="directurl" />
```

Interpretation from evidence:

- `selector="directurl"` identifies the stock source as `My Streams`.
- The `state` attribute embeds the same stream entry stored in `/psp/url_streams`.
- `/tmp/musicsource` appears to record the currently selected/playing music source state.
- The file is evidence of the active stock music source, but it is not yet proven to be a command trigger.

The USB copy of `docs/Chumby_tricks` lists `directurl` as the selector for `My Streams`, matching the observed `/tmp/musicsource` value.
## Event File Trigger Test

A minimal stock event-file test was performed on 2026-08-15:

```sh
echo '<event type="UserPlayer" value="play" comment="http://localhost/music.m3u"/>' > /tmp/flashplayer.event
```

Snapshot evidence from `music-player-event-play-test.txt`:

```text
/tmp/flashplayer.event exists, timestamp 09:38, size 77
<event type="UserPlayer" value="play" comment="http://localhost/music.m3u"/>
```

The recent lighttpd access log in the same snapshot only contained older music requests from 09:34:

```text
[15/Aug/2026:09:34:51 +0200] "GET /music.m3u HTTP/1.1" 301
[15/Aug/2026:09:34:54 +0200] "GET /cgi-bin/randomshuffler.sh HTTP/1.1" 200
```

No new FlashLite request to `/music.m3u` was observed after the 09:38 event-file write. `/tmp/musicsource` was also absent from the snapshot.

Interpretation from evidence:

- Writing `/tmp/flashplayer.event` with `UserPlayer play` and the exact working URL did not reproduce the stock touchscreen Play path.
- The event file persisted, which suggests this runtime was not consuming that file in the same way as the stock Music Player action.
- The stock Play trigger remains internal to the FlashLite Music Player path or uses a different command channel than this simple event-file write.
## Flash Command FIFO Finding

Hardware inspection on 2026-08-15 confirmed the Flash command paths are FIFOs:

```text
prw-r--r-- 1 root root 0 Aug 15 09:48 /tmp/.fpcmdrecv
prw-r--r-- 1 root root 0 Aug 15 09:48 /tmp/.fpcmdsend
```

Interpretation from evidence:

- The leading `p` in the mode indicates named pipes.
- `chumbpipe` is running with `/tmp/.fpcmdsend` and `/tmp/.fpcmdrecv`.
- These paths are plausible FlashLite command transport internals.
- Do not write to these FIFOs until the protocol is known; blind writes could block or destabilize the Control Panel.
## Chumbpipe File Descriptor Finding

Hardware inspection identified the active `chumbpipe` process and its open file descriptors:

```text
2699 root sh -c chumbpipe /tmp/.fpcmdsend /tmp/.fpcmdrecv
2700 root chumbpipe /tmp/.fpcmdsend /tmp/.fpcmdrecv
```

```text
/proc/2700/fd/3 -> socket:[4179]
/proc/2700/fd/4 -> /tmp/.fpcmdsend
/proc/2700/fd/5 -> /tmp/.fpcmdrecv
```

Interpretation from evidence:

- `chumbpipe` has a socket open in addition to the two FIFOs.
- fd `4` is read-only and points at `/tmp/.fpcmdsend`.
- fd `5` is write-only and points at `/tmp/.fpcmdrecv`.
- This suggests `.fpcmdsend` is the input side for commands into `chumbpipe`, while `.fpcmdrecv` is the response/output side.
- The command protocol is still unknown; no FIFO writes should be attempted yet.
## Control Panel Ownership Finding

Hardware inspection of `/usr/chumby/scripts/start_control_panel` confirmed which SWF owns the stock Music Player UI.

Observed script behavior:

```text
DEFAULT_CP=/usr/widgets/controlpanel.swf
if [ -f /mnt/usb/controlpanel.swf ]; then
    ALTERNATE=1
    CP_PATH=/mnt/usb/controlpanel.swf
    DOWNLOADED=1
fi
```

Observed files:

```text
/mnt/usb/controlpanel.swf       591602 bytes
/usr/widgets/controlpanel.swf   580993 bytes
```

Interpretation from evidence:

- The running Control Panel is expected to use `/mnt/usb/controlpanel.swf` when present.
- This USB SWF is the likely owner of the stock Music Player, My Streams UI, and touchscreen Play action.
- The Play trigger is therefore likely inside the alternate USB Control Panel SWF, not in `chumbpipe` itself.
## Control Panel Launch Finding

Hardware inspection of `/usr/chumby/scripts/start_control_panel` lines 160-260 showed the exact Control Panel launch flow:

```sh
echo 1 >/tmp/flashheartbeat
echo 1 >/tmp/movieheartbeat
echo 1 >/tmp/flashplayer_started
/usr/sbin/btplayd >/dev/null 2>&1 &
/usr/bin/chumbyflashplayer.x -i $CP $CP_ARGS
```

Earlier lines in the same script select `/mnt/usb/controlpanel.swf` as `$CP` when present.

Interpretation from evidence:

- `btplayd` is started immediately before the Control Panel FlashLite process.
- `chumbyflashplayer.x` owns the selected Control Panel SWF runtime.
- The USB `/mnt/usb/controlpanel.swf` is the active SWF owner of the Music Player UI when present.
- `start_control_panel` does not expose a separate shell-level music Play command.

A plain `strings /mnt/usb/controlpanel.swf` search for `musicsource`, `directurl`, `url_streams`, `music.m3u`, `UserPlayer`, `MusicPlayer`, `randomshuffler`, `fpcmd`, `chumbpipe`, and `play` returned no matches. This suggests the useful SWF internals are compressed, encoded, or otherwise not visible via plain `strings`.
## Control Panel SWF Compression Finding

Windows-side header inspection of `E:\controlpanel.swf` showed:

```text
43 57 53 06 E2 A3 16 00
CWS
```

Interpretation:

- `CWS` identifies a zlib-compressed SWF.
- SWF version byte is `06`.
- Plain `strings /mnt/usb/controlpanel.swf` returned no useful music symbols because the SWF body is compressed.
- Further trigger analysis should happen offline on the PC by decompressing the SWF body, not by stressing the Chumby.
## Decompressed Control Panel SWF Finding

The active USB Control Panel SWF was decompressed offline and searched on the Windows PC. The generated files are evidence artifacts only:

```text
D:\GitHub\ha-chumby\controlpanel.decompressed.swf
D:\GitHub\ha-chumby\controlpanel-search-results.txt
```

Do not commit these generated files unless the project later decides to keep a sanitized reverse-engineering artifact.

Search summary:

| Pattern | Count | First observed line |
| --- | ---: | ---: |
| `musicSource` | 21 | 10 |
| `directurl` | 48 | 3 |
| `url_streams` | 2 | 11 |
| `MusicPlayer` | 26 | 10 |
| `UserPlayer` | 2 | 10 |
| `music.m3u` | 0 | n/a |
| `randomshuffler` | 0 | n/a |
| `fpcmd` | 0 | n/a |
| `chumbpipe` | 0 | n/a |

Relevant symbols found in the decompressed SWF include:

```text
DirectURLStreams.loadStreams()
/psp/url_streams
DirectURLPlayer.playStream()
DirectURLPlayer.playStream(): M3U
playM3U
DirectURLPlayer.gotM3U()
DirectURLPlayer.playURL()
DirectURLPlayer.doStartTrack()
DirectURLPlayer.doStopTrack()
DirectURLPanelMain.doPlay()
ExternalMusicCallbacks.setMusicSource
```

Interpretation:

- The active Control Panel SWF contains the stock Direct URL / My Streams UI and playback logic.
- `DirectURLPanelMain.doPlay()` is the strongest static symbol corresponding to the touchscreen Play button.
- The literal `music.m3u` and `randomshuffler.sh` strings were not found; the SWF receives the stream URL from `/psp/url_streams` and follows the HTTP redirect at runtime.
- The SWF contains M3U and PLS parsing/player code, which explains why the working path depends on FlashLite state rather than simply fetching a playlist from outside the Chumby UI.
- The search did not identify an external FIFO command, socket command, or shell command that can safely reproduce the Play action.

This finding strengthens the conclusion that the next proof-of-concept must either invoke an existing SWF-exposed command with known protocol semantics or preserve the stock Music Player state and control its input data. Blind writes to `/tmp/.fpcmdsend` remain out of scope until the protocol is known.
## Stock Stop Transition Finding

Hardware snapshots from 2026-08-24 captured the stock Music Player before Play, while playing, and after pressing Stop.

| Snapshot | Time | Key observation |
| --- | --- | --- |
| `before-stock-play` | 19:56:32 | `/tmp/musicsource` was absent; `btplayd` PID `1476` was already running. |
| `stock-playing` | 19:58:33 | `/tmp/musicsource` existed with the `Random music` Direct URL source; `btplayd` PID remained `1476`. |
| `stock-stopped` | 19:59:40 | `/tmp/musicsource` was absent again; `btplayd` PID still remained `1476`. |

The playing state file contained:

```xml
<musicSource state="&lt;stream url=&quot;http://localhost/music.m3u&quot; id=&quot;&quot; mimetype=&quot;audio/x-mpegurl&quot; name=&quot;Random music&quot; /&gt;" label="Random music" selector="directurl" />
```

The stopped state capture `E:\ha-chumby\musicsource-stock-stopped.xml` was zero bytes because `/tmp/musicsource` no longer existed after Stop.

Interpretation:

- `/tmp/musicsource` tracks the active stock music source lifecycle: created by Play, removed by Stop.
- Stop does not restart `btplayd`.
- The recent lighttpd music log lines showed the FlashLite `/music.m3u` and `/cgi-bin/randomshuffler.sh` requests for Play, but no new Stop HTTP request.
- Stock Stop is therefore also likely an internal FlashLite player action rather than a reusable CGI endpoint observed in this capture.
## Proof-of-Concept Status

No proof-of-concept was added.

Reason: the original trigger has not yet been identified from hardware evidence. A proof-of-concept would be premature until the snapshots reveal a specific reusable mechanism.

## Lightweight Snapshot Validation

Hardware validation confirmed the reduced snapshot helper is safe enough for Sprint 14 testing.

Observed result on 2026-08-14:

```yaml
before_play_snapshot: completed
selected_snapshot: completed
after_play_snapshot: completed
playing_snapshot: completed
freeze: false
```

This supersedes the earlier full snapshot helper, which made the Chumby stop responding. Continue using only the lightweight helper for trigger investigation.
## Runtime Recovery Finding

Hardware SSH evidence on 2026-08-14 showed that the Zork runtime was restored after removing automatic stock music trigger probing and copying LF-only shell scripts to the USB stick.

Observed runtime evidence:

```text
/mnt/usb/lighty/sbin/lighttpd -f /mnt/usb/lighty/lighttpd.conf
0.0.0.0:80 LISTEN
GET / HTTP/1.1 -> 200
GET /cgi-bin/logs.sh HTTP/1.1 -> 200
GET /cgi-bin/chumote/index.cgi HTTP/1.1 -> 200
GET /music.m3u HTTP/1.1 -> 301 /cgi-bin/randomshuffler.sh
GET /cgi-bin/randomshuffler.sh HTTP/1.1 -> 200
```

This means the earlier `404` result was not the final restored runtime state. The active runtime is lighttpd using `/mnt/usb/lighty/lighttpd.conf`, not the early BusyBox-only HTTP state.

The boot log also showed that BusyBox `find` on the Chumby does not support `-maxdepth`. Sprint 14 diagnostics were updated to avoid `find -maxdepth`.
## Expected Hardware Validation

After preparing the USB and booting:

1. The HA-Chumby splash appears.
2. The original UI starts.
3. `Random music` remains available in the stock Music Player.
4. The stock UI still plays audio when `Random music` is started manually.
5. Snapshot files are created on the USB stick.
6. The snapshot comparison identifies what changed when Play was pressed.

## Rollback

To return to the previous USB contents, restore the last known working USB backup or rerun the previous installer revision. No internal flash rollback is required because Sprint 14 changes only USB-side files.

## Remaining Unknowns

- The exact stock Play-button trigger.
- Whether the trigger is a file write, CGI request, socket message, signal, or internal FlashLite state transition.
- Whether the trigger can be invoked programmatically without changing the stock player.
- Whether a future MVP can control local wake music by preserving the stock player path and updating playlist inputs only.
