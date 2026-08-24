# Sprint 15 Implementation

Status: documentation and diagnostics only.

## Goal

Sprint 15 investigates how the stock FlashLite Control Panel starts the proven `Random music` playback path. It does not implement Home Assistant integration, replace the player, modify FlashLite, modify `btplayd`, or change runtime behavior.

## Changes Made

| File | Change |
| --- | --- |
| `docs/FLASHLITE_TRIGGER.md` | Added Sprint 15 trigger knowledge base, evidence, rejected triggers, IPC notes, and proof-of-concept status. |
| `docs/SPRINT15_IMPLEMENTATION.md` | Added this implementation summary. |
| `installer/overlay/ha-chumby/music-player-snapshot.sh` | Extended read-only diagnostics for FlashLite trigger investigation. |

## Diagnostic Updates

The snapshot helper now captures additional state relevant to Sprint 15:

```text
/tmp/.fpcmdsend
/tmp/.fpcmdrecv
/tmp/flashheartbeat
/tmp/movieheartbeat
/tmp/flashplayer_started
```

It also logs focused process lines for:

```text
chumbyflashplayer
btplayd
chumbpipe
start_control_panel
```

These additions do not start playback, stop playback, write command FIFOs, write `/tmp/musicsource`, or alter player state.

## Hardware Evidence Incorporated

Sprint 15 starts from the 2026-08-24 stock Play/Stop snapshots:

| Snapshot | Observation |
| --- | --- |
| `music-player-before-stock-play.txt` | `/tmp/musicsource` absent; `btplayd` PID `1476`. |
| `music-player-stock-playing.txt` | `/tmp/musicsource` present; FlashLite fetched `/music.m3u` and `/cgi-bin/randomshuffler.sh`; `btplayd` PID `1476`. |
| `music-player-stock-stopped.txt` | `/tmp/musicsource` absent again; `btplayd` PID `1476`. |
| `musicsource-stock-playing.xml` | Direct URL source state for `Random music`. |
| `musicsource-stock-stopped.xml` | Zero bytes because the file was absent after Stop. |

The Sprint 15 hardware validation repeated the same lifecycle with the updated diagnostic helper:

| Snapshot | Time | Observation |
| --- | --- | --- |
| `music-player-sprint15-before-play.txt` | 20:49:53 | `/tmp/musicsource` absent; `btplayd` PID `1464`; Flash command FIFOs present. |
| `music-player-sprint15-playing.txt` | 20:51:51 | `/tmp/musicsource` present; FlashLite fetched `/music.m3u` and `/cgi-bin/randomshuffler.sh`; `btplayd` PID `1464`. |
| `music-player-sprint15-stopped.txt` | 20:52:29 | `/tmp/musicsource` absent again; no new stop HTTP request in the captured music log lines; `btplayd` PID `1464`. |

Additional Sprint 15 diagnostic evidence:

- `/tmp/.fpcmdsend` and `/tmp/.fpcmdrecv` existed before Play, while playing, and after Stop.
- Their timestamps changed from 20:32 before Play to 20:50 while playing and 20:52 after Stop.
- `chumbpipe /tmp/.fpcmdsend /tmp/.fpcmdrecv` remained running in all snapshots.
- The FIFO timestamp changes are evidence of activity or refresh, but they do not reveal the protocol and do not justify blind writes.

## Current Implementation Decision

No proof-of-concept was implemented.

Reason: no safe external trigger has been identified. The evidence still points to an internal FlashLite action:

```text
DirectURLPanelMain.doPlay()
-> DirectURLPlayer.playStream()
-> M3U handling
-> native audio-player calls
-> btplayd
```

The project should not fake this by writing unproven state files or by sending blind messages to `/tmp/.fpcmdsend`.

## Validation Steps

After copying the updated snapshot helper to the USB stick, use this sequence on hardware:

```sh
sh /mnt/usb/ha-chumby/music-player-snapshot.sh sprint15-before-play
```

Then on the touchscreen:

```text
Music Player -> My Streams -> Random music -> Play
```

When audio is heard:

```sh
sh /mnt/usb/ha-chumby/music-player-snapshot.sh sprint15-playing
```

Then press stock Stop on the touchscreen:

```sh
sh /mnt/usb/ha-chumby/music-player-snapshot.sh sprint15-stopped
```

Collect:

```text
E:\ha-chumby\music-player-sprint15-before-play.txt
E:\ha-chumby\music-player-sprint15-playing.txt
E:\ha-chumby\music-player-sprint15-stopped.txt
```

Expected evidence:

- `/tmp/musicsource` absent before Play.
- `/tmp/musicsource` present while playing.
- `/tmp/musicsource` absent after Stop.
- `btplayd` PID remains stable.
- FlashLite-originated `/music.m3u` request appears for Play.
- No blind FIFO writes or runtime modifications occur.

## Rollback

Rollback is USB-only:

1. Restore the previous `music-player-snapshot.sh`, or rerun the previous installer revision.
2. Reboot the Chumby with the USB stick.

No internal flash rollback is required.

## Remaining Work

- Determine whether FlashLite exposes a safe command mechanism for `DirectURLPanelMain.doPlay()`.
- If a command mechanism is discovered, build a minimal proof-of-concept that invokes the stock Play path.
- If no safe command mechanism exists, design the MVP around preserving the stock Music Player path and controlling its input data.
