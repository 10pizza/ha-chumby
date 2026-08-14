# Sprint 13 Implementation

Status: Sprint 13 FlashLite audio pipeline reverse engineering.

## Goal

Understand and reuse the proven stock FlashLite audio path rather than replacing it.

## Findings So Far

Hardware and USB inspection show the working stock path is based on `/psp/url_streams` and `/music.m3u`:

```text
/psp/url_streams -> http://localhost/music.m3u -> lighttpd redirect -> /cgi-bin/randomshuffler.sh -> /mnt/usb/music/*.mp3 playlist -> FlashLite audio
```

The web log evidence from audible playback was:

```text
GET /music.m3u HTTP/1.1
GET /cgi-bin/randomshuffler.sh HTTP/1.1
```

## CloudFront replacement

The original Sprint 13 experiment used the earlier Omrop Fryslan URL from Sprint 12. Hardware validation found that stream was no longer usable, so the experiment was updated to:

```text
https://d3pvma9xb2775h.cloudfront.net/icecast/omropfryslan/radio.mp3
```

This replacement updates only USB configuration and documented installer defaults; it still preserves the stock FlashLite playback architecture.

## USB Experiment Applied

On the mounted USB stick, Sprint 13 backed up:

```text
/psp/url_streams
```

as:

```text
/psp/url_streams.sprint13-original
```

Then `/psp/url_streams` was replaced with exactly one stream entry:

```xml
<streams><stream url="https://d3pvma9xb2775h.cloudfront.net/icecast/omropfryslan/radio.mp3" id="" mimetype="audio/mpeg" name="Omrop Fryslan" /></streams>
```

The USB manifest was updated with the experiment note.


## Direct MP3 Experiment Result

Hardware validation showed the stock widget reads the modified stream configuration:

```yaml
station_visible: Omrop Fryslan
type_visible: mp3
```

Playback failed. This confirms `/psp/url_streams` is the correct configuration source for the stock widget, but a direct `https` MP3 stream with `audio/mpeg` is not sufficient for this FlashLite path.

Next experiment: keep `/psp/url_streams` as the configuration mechanism, but point it to a local M3U wrapper because the proven working path used `audio/x-mpegurl`.

```xml
<streams><stream url="http://localhost/omrop-fryslan.m3u" id="" mimetype="audio/x-mpegurl" name="Omrop Fryslan" /></streams>
```

The wrapper file contained exactly:

```text
https://d3pvma9xb2775h.cloudfront.net/icecast/omropfryslan/radio.mp3
```

Hardware result: the station still did not produce audio. This rejects the simple M3U-wrapper hypothesis for the tested HTTPS stream.

## M3U Wrapper Experiment Result

Hardware validation after changing `/psp/url_streams` to `http://localhost/omrop-fryslan.m3u` with MIME type `audio/x-mpegurl` still produced no audio.

```yaml
station_visible: likely yes
playlist_wrapper: http://localhost/omrop-fryslan.m3u
playlist_contents: https://d3pvma9xb2775h.cloudfront.net/icecast/omropfryslan/radio.mp3
audio: failed
```

This means the failure is not only the MIME type in `/psp/url_streams`. The known-good `/music.m3u` response is a plain LF-separated local file path list; the failed wrapper contained a remote HTTPS URL.

## Known-Good music.m3u Response

Hardware capture of `Invoke-WebRequest "http://192.168.1.104/music.m3u"` returned bytes. Decoded as ASCII, the response is a plain newline-separated list of absolute local MP3 paths.

Observed properties:

```yaml
entry_count: 27
encoding: ASCII
line_separator: LF
format: one absolute /mnt/usb/music/*.mp3 path per line
header: none
remote_urls: none
playlist_metadata: none
```

First entries:

```text
/mnt/usb/music/MIT_Concert_Choir_-_01_-_O_Fortuna.mp3
/mnt/usb/music/MIT_Concert_Choir_-_02_-_Fortune_planto_vulnera.mp3
/mnt/usb/music/MIT_Concert_Choir_-_03_-_Veris_leta_facies.mp3
/mnt/usb/music/MIT_Concert_Choir_-_04_-_Omnia_sol_temperat.mp3
/mnt/usb/music/MIT_Concert_Choir_-_05_-_Ecce_gratum.mp3
```

Last entries:

```text
/mnt/usb/music/MIT_Concert_Choir_-_23_-_Dulcissime.mp3
/mnt/usb/music/MIT_Concert_Choir_-_24_-_Ave_formosissima__O_Fortuna_reprise.mp3
/mnt/usb/music/apollo.mp3
/mnt/usb/music/hal.mp3
/mnt/usb/music/sample.mp3
```

This explains why the previous M3U wrapper was not equivalent to the working path: the working playlist contains local absolute file paths, not a remote HTTPS URL.

A single local playlist wrapper containing `/mnt/usb/music/sample.mp3` was tested through the Zurk/Chumote Play URL control and produced no audio. This means matching the playlist body alone is not sufficient when playback is initiated through that control path.

## Browser Playlist Fetch Findings

On 2026-08-14, direct browser/PowerShell tests fetched playlist endpoints from a PC at `192.168.1.99`.

| Test URL | HTTP result | Audio result | Interpretation |
| --- | --- | --- | --- |
| `http://192.168.1.104/cgi-bin/music.m3u` | Returned the same local MP3 path list as `randomshuffler.sh`. | No audio. | Browser fetch proves playlist generation only; it does not invoke the Chumby FlashLite player. |
| `http://192.168.1.104/cgi-bin/randomshuffler.sh` | Returned LF-separated `/mnt/usb/music/*.mp3` paths. | No audio. | Expected: this CGI only returns playlist text and does not launch playback. |
| `http://192.168.1.104/sample-local.m3u` | HTTP 404. | No audio. | The test file was not present under lighttpd document root at test time. |
| `http://192.168.1.104/omrop-fryslan.m3u` | HTTP 200, 69 byte response. | No audio. | Browser fetch of the playlist wrapper does not prove Chumby playback; the stock widget must request and play it. |

The web log showed these PC-originated requests as browser requests, not FlashLite player requests:

```text
192.168.1.99 192.168.1.104 - [14/Aug/2026:07:59:40 +0200] "GET /cgi-bin/randomshuffler.sh HTTP/1.1" 200 1631 "-" "Mozilla/5.0 ... Chrome ..."
192.168.1.99 192.168.1.104 - [14/Aug/2026:08:07:28 +0200] "GET /sample-local.m3u HTTP/1.1" 404 345 "-" "Mozilla/5.0 ... Chrome ..."
192.168.1.99 192.168.1.104 - [14/Aug/2026:08:09:13 +0200] "GET /omrop-fryslan.m3u HTTP/1.1" 200 69 "-" "Mozilla/5.0 ... Chrome ..."
```

For playback validation, the source of the request matters. A useful positive test must show the stock FlashLite widget requesting the playlist and audio being heard, not only a desktop browser receiving playlist text.

## Sample Local Playlist Experiment Result

The next controlled local-file playlist test also failed to produce audio.

```yaml
playlist_url: http://localhost/sample-local.m3u
playlist_body: /mnt/usb/music/sample.mp3
format: single LF-terminated local absolute MP3 path
started_from: Zurk/Chumote Play URL control
audio: failed
```

This rejects the hypothesis that any user-provided `UserPlayer` playlist URL using the known-good body format is sufficient. The remaining proven audible behavior is more specific: the stock FlashLite music/radio widget selecting the built-in `Random music` entry, which points at `http://localhost/music.m3u` and internally follows the `/cgi-bin/randomshuffler.sh` path.
## Confirmed Stock Player Playback Evidence

On 2026-08-14, hardware validation confirmed audible playback through the original stock music UI.

```yaml
ui_path: Stock Music Player -> My Streams -> Random music
user_action: Press Play
visible_status: Now Playing: Random music
audio: heard through speaker
startup_delay: noticeable
volume_initially_responsive: false
volume_later_responsive: true
```

Captured framebuffer evidence:

| File | Evidence |
| --- | --- |
| `C:\Users\Surface\Desktop\chumby-playing-fb1.jpg` | The music overlay shows `My Streams`, `Now Playing: Random music`, the `Random music` entry, playback controls, and volume slider. |
| `C:\Users\Surface\Desktop\chumby-playing-fb0.jpg` | The main framebuffer shows a stock AccuWeather widget loading while the music overlay remains available separately on framebuffer 1. |

Captured process evidence from `C:\Users\Surface\Desktop\chumby-playing-top.txt` while music was playing:

```text
PID 2641 root RW 20440 41644 ... 79.5% CPU chumbyflashplay
PID 1442 root SW< 2540 6188 ... 17.4% CPU btplayd
PID 2378 root SW 1200 2564 ... lighttpd
Load average: 3.47 3.45 2.35
```

Captured playlist evidence from `C:\Users\Surface\Desktop\chumby-playing-music-m3u.txt`:

```yaml
entry_count: 27
format: plain LF-separated absolute local MP3 paths
source_paths: /mnt/usb/music/*.mp3
remote_urls: none
headers: none
```

First entries:

```text
/mnt/usb/music/MIT_Concert_Choir_-_01_-_O_Fortuna.mp3
/mnt/usb/music/MIT_Concert_Choir_-_02_-_Fortune_planto_vulnera.mp3
/mnt/usb/music/MIT_Concert_Choir_-_03_-_Veris_leta_facies.mp3
/mnt/usb/music/MIT_Concert_Choir_-_04_-_Omnia_sol_temperat.mp3
/mnt/usb/music/MIT_Concert_Choir_-_05_-_Ecce_gratum.mp3
```

Last entries:

```text
/mnt/usb/music/MIT_Concert_Choir_-_23_-_Dulcissime.mp3
/mnt/usb/music/MIT_Concert_Choir_-_24_-_Ave_formosissima__O_Fortuna_reprise.mp3
/mnt/usb/music/apollo.mp3
/mnt/usb/music/hal.mp3
/mnt/usb/music/sample.mp3
```

The captured lighttpd logs mostly show browser polling of the Zork/Chumote page and framebuffer endpoints during this evidence capture. The audio-positive observation came from the physical stock UI action, not from a desktop HTTP request.

This is now the best-known reusable path for MVP wake audio: preserve the stock `Random music` entry and determine how to trigger that exact stock player action programmatically.
## Repository Changes

`installer/overlay/ha-chumby/start.sh` now logs FlashLite audio pipeline diagnostics at boot, including:

- `/psp/url_streams`
- `/psp/url_streams.sprint13-original`
- `randomshuffler.sh`
- `player.sh`
- `save_streams.sh`
- `chum.js`
- lighttpd `/music.m3u` redirect and CGI mapping
- USB music inventory

## Validation Checklist

After booting with the USB stick:

1. Confirm the original Chumby UI starts.
2. Open the same stock radio/music widget that previously played random audio.
3. Confirm whether the available station is now `Omrop Fryslan`.
4. Start playback.
5. Record whether audio is heard.
6. Run:

```powershell
$r = Invoke-WebRequest "http://192.168.1.104/cgi-bin/logs.sh"
$r.Content
```

7. After reboot or USB removal, inspect:

```text
E:\ha-chumby\boot-diagnostics.txt
```

Look for:

```text
flashlite audio pipeline diagnostics
/psp/url_streams
randomshuffler.sh
music.m3u
```

## Interpretation Matrix

| Result | Interpretation | Next action |
| --- | --- | --- |
| Omrop Fryslan plays audibly from stock widget | Direct stream entries in `/psp/url_streams` are reusable for MVP. | Use `/psp/url_streams` as the radio configuration mechanism. |
| Station appears as `Omrop Fryslan` with type `mp3` but does not play | Confirmed: stock widget sees `/psp/url_streams`, but direct `https` MP3 playback failed. | M3U wrapper was tested next and also failed. |
| Local M3U wrapper through Play URL does not play | Confirmed: `http://localhost/sample-local.m3u` containing `/mnt/usb/music/sample.mp3` produced no audio through the Zurk/Chumote Play URL control. | Stop using Play URL as proof of the stock widget path; test by selecting the actual stream entry inside the stock FlashLite music/radio widget. |
| Station does not appear | UI reads a different stream source or cached state. | Inspect `music_sources/show`, FlashLite logs, and profile data. |
| Random music still appears and plays | This remains the only confirmed audible stock FlashLite path. | Preserve and inspect this exact entry/path before changing it further. |

## Rollback

Restore the original USB configuration:

```powershell
Copy-Item E:\psp\url_streams.sprint13-original E:\psp\url_streams -Force
```

## Not Changed

Sprint 13 does not:

- modify internal flash
- replace FlashLite
- replace `btplayd`
- add Home Assistant logic
- add alarm logic
- create a new playback engine
