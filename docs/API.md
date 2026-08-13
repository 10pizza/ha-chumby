# HA-Chumby Control API Inventory

Status: Sprint 5 discovery document.

Scope: Existing Zurk Offline Firmware v21 interfaces discovered on the prepared USB stick. This document inventories reusable endpoints only. It does not define a new REST API and does not implement Home Assistant integration.

Discovery source: USB filesystem mounted at `E:\` on 2026-08-13. Important inspected files include `E:\README.TXT`, `E:\lighty\lighttpd.conf`, `E:\lighty\html\index.html`, `E:\lighty\html\chum.js`, `E:\lighty\cgi-bin\*.sh`, `E:\lighty\cgi-bin\custom\*.sh`, and `E:\lighty\cgi-bin\chumote\*.cgi`.

## Server Model

| Item | Value | Evidence |
| --- | --- | --- |
| Document root | `/mnt/usb/lighty/html` | `E:\lighty\lighttpd.conf` |
| CGI alias | `/cgi-bin/` maps to `/mnt/usb/lighty/cgi-bin/` | `E:\lighty\lighttpd.conf` |
| CGI interpreters | `.sh` and `.cgi` use `/bin/sh`; `.pl` uses `/mnt/usb/perl/perl`; `.php` uses `/mnt/usb/php/php-cgi`; `.py` uses `/mnt/usb/python/bin/python` | `E:\lighty\lighttpd.conf` |
| Status endpoint | `/server-status` | `E:\lighty\lighttpd.conf` |
| Web control panel | `http://<chumby-ip>/` | `E:\README.TXT`, `E:\lighty\html\index.html` |

Base URL examples use:

```text
http://<chumby-ip>
```

## MVP-Relevant Endpoints

| Category | URL | Parameters | Purpose | Expected result | MVP usefulness |
| --- | --- | --- | --- | --- | --- |
| TTS | `/cgi-bin/speak.pl?action=say&words=<text>` | `action=say`, `words` text | Speak arbitrary text using `flite_cmu_us_kal16`. | Returns `done=true`; audio speaks text. | Directly useful for wake prompts. |
| TTS | `/cgi-bin/speak.pl?action=time&time=HH:MM` | `action=time`, `time` | Speak a time using `flite_time`. | Returns `done=true`; audio speaks time. | Useful for morning routine. |
| TTS | `/cgi-bin/speak.pl` | none | Speak current local time. | Returns `done=true`; audio speaks time. | Useful diagnostic. |
| Media Playback | `/cgi-bin/zmote_play.sh?<url-or-path>` | Raw query string becomes play URL/path. | Send `UserPlayer play` event to Flash player. | Requested URL/path starts playing if Flash player accepts it. | Directly useful for MP3/music URL playback. |
| Media Playback | `/cgi-bin/zmote_playloop.sh?<url-or-path>` | Raw query string becomes loop URL/path. | Send `UserPlayer playLoop` event. | Requested URL/path loops if supported. | Useful for looping wake audio. |
| Media Playback | `/cgi-bin/custom/multistreams.sh?stop` | `stop` | Send `MusicPlayer stop` event. | Music stops. | Directly useful for stopping wake audio. |
| Media Playback | `/cgi-bin/chumote/event.cgi?stopMusic` | `stopMusic` command | Send `MusicPlayer stop` event. | Music stops. | Directly useful stop endpoint. |
| Volume | `/cgi-bin/custom/setvol.sh?<0-100>` | Raw query string volume, documented 0-100. | Send `MusicPlayer setVolume` event. | Volume changes; response says volume set. | Directly useful before wake playback. |
| Volume | `/cgi-bin/chumote/event.cgi?setVolume0` | fixed command | Set volume to 0. | Volume muted by volume event. | Useful for muting. |
| Volume | `/cgi-bin/chumote/event.cgi?setVolume50` | fixed command | Set volume to 50. | Volume set to 50. | Useful preset. |
| Volume | `/cgi-bin/chumote/event.cgi?setVolume100` | fixed command | Set volume to 100. | Volume set to 100. | Useful preset. |
| Volume | `/cgi-bin/custom/setmute.sh` | none | Send `MusicPlayer setMute` event with comment `on`. | Mutes music player. | Useful but no unmute variant present as separate script. |
| Display | `/cgi-bin/message.sh?<text>` | Raw query string text. | Write query string to `../html/msg.txt`. | Response says message set; text available to message widget/header. | Useful if message widget/profile is active. |
| Display | `/cgi-bin/fb.sh` | optional cachebuster ignored. | Capture framebuffer 0. | JPEG image response, refresh header. | Useful for remote validation. |
| Display | `/cgi-bin/fb1.sh` | optional cachebuster ignored. | Capture framebuffer 1. | JPEG image response, refresh header. | Useful for remote validation. |
| Brightness | `/cgi-bin/custom/off.sh` | none | Write `2` to `/proc/sys/sense1/dimlevel`. | Display off mode requested. | Useful for bedtime/screen off. |
| Brightness | `/cgi-bin/custom/dim.sh` | none | Write `0`, wait, then write `1` to dimlevel. | Display enters dim mode. | Useful for nighttime. |
| Brightness | `/cgi-bin/chumote/event.cgi?bright` | fixed command | Send `ScreenManager bright` event. | Screen bright event sent to Flash player. | Useful if stock UI handles event. |
| Brightness | `/cgi-bin/chumote/event.cgi?dim` | fixed command | Send `ScreenManager dim` event. | Screen dim event sent to Flash player. | Useful if stock UI handles event. |
| Brightness | `/cgi-bin/chumote/event.cgi?off` | fixed command | Send `ScreenManager off` event. | Screen off event sent to Flash player. | Useful if stock UI handles event. |
| System | `/cgi-bin/sync.sh` | none | Run `sync`. | USB/storage writes flushed. | Useful after configuration edits. |
| System | `/cgi-bin/chumote/control.cgi?cp_stop` | `cp_stop` | Call `stop_control_panel`. | Control Panel stops. | Useful only with caution; may disrupt stock UI. |
| System | `/cgi-bin/chumote/control.cgi?cp_restart` | Intended command, but script has `cd_restart` case typo. | UI shows restart, script case appears mismatched. | May not work as linked. | Not reliable without hardware test. |

## Complete Endpoint Inventory

### Lighttpd Redirects

These routes are defined by `E:\lighty\lighttpd.conf`.

| Category | URL | Target | Parameters | Purpose / expected result |
| --- | --- | --- | --- | --- |
| Widgets | `/xml/profiles/<suffix>` | `/cgi-bin/profiles.sh<suffix>` | Profile id in query string. | Return profile XML for Classic/One-style widget profiles. |
| Widgets | `/xml/setprofile?<query>` | `/cgi-bin/profiles.sh<query>` | Profile id in query string. | Return profile XML; name suggests setprofile compatibility. |
| Radio | `/chumcast/show?<query>` | `/cgi-bin/tune.sh...` | Query transformed by `tune.sh`. | Return chumcast `xshow_...` content. |
| Radio | `/station_list/format?<query>` | `/cgi-bin/format.sh<query>` | Format id. | Return station list file `format<ID>`. |
| Widgets | `/device/show?<query>` | `/cgi-bin/show.sh<query>` | Profile id. | Return xAPI device profile show document. |
| Widgets | `/device/profiles/show?<query>` | `/cgi-bin/show.sh<query>` | Profile id. | Return xAPI profile show document. |
| Media Playback | `/music.m3u` | `/cgi-bin/randomshuffler.sh` | none | Return shuffled list of `/mnt/usb/music/*.mp3`. |
| Radio | `/station_list/city?<query>` | `/cgi-bin/city.sh<query>` | City id. | Return station list file `city<ID>`. |
| Radio | `/shoutcast/show?<query>` | External Shoutcast PLS URL | Shoutcast parameters. | Redirect to Shoutcast tune-in PLS endpoint. |
| Radio | `/shoutcast/search?<query>` | `/cgi-bin/search.sh?<query>` | Search string. | Return Shoutcast stationlist XML. |
| Display | `/photos/images.xml` | `/cgi-bin/createindex.sh` | none | Generate photo image XML from `lighty/html/photos/*.jpg`. |

### Top-Level CGI Scripts

| Category | URL | Script | Parameters | Purpose | Expected result |
| --- | --- | --- | --- | --- | --- |
| System | `/cgi-bin/blackbox.sh` | `blackbox.sh` | none | Show blackbox/orangebox/crashbox logs. | HTML preformatted log output. |
| Radio | `/cgi-bin/city.sh?<id>` | `city.sh` | id parsed from query after `=`. | Return `station_list/city<ID>`. | Station list text/XML. |
| Display | `/cgi-bin/createindex.sh` | `createindex.sh` | none | Generate XML image list for photos. | `<images>` XML. |
| System | `/cgi-bin/dlna.sh` | `dlna.sh` | none | Show DLNA enabled/queued/disabled status. | HTML status page. |
| System | `/cgi-bin/dmesg.sh` | `dmesg.sh` | none | Show kernel log, top, uptime, free, ifconfig. | HTML diagnostics. |
| Misc | `/cgi-bin/event.sh?<event-xml>` | `event.sh` | Raw query intended as event XML. | Experimental Flash event writer. | Script says it does not work due to ash limitations. |
| Display | `/cgi-bin/fb.sh` | `fb.sh` | optional cachebuster. | Capture framebuffer 0 with `imgtool`. | JPEG image. |
| Display | `/cgi-bin/fb1.sh` | `fb1.sh` | optional cachebuster. | Capture framebuffer 1 with `imgtool`. | JPEG image. |
| Radio | `/cgi-bin/format.sh?<id>` | `format.sh` | id parsed from query after `=`. | Return `station_list/format<ID>`. | Station list text/XML. |
| Misc | `/cgi-bin/helloworld.php` | `helloworld.php` | none | PHP test endpoint. | PHP info output. |
| Misc | `/cgi-bin/helloworld.py` | `helloworld.py` | none | Python CGI test. | Hello World HTML. |
| Misc | `/cgi-bin/helloworld.pl` | `helloworld.pl` | none | Perl CGI test. | Hello world text. |
| System | `/cgi-bin/license.sh` | `license.sh` | none | Show GPL license file. | HTML license output. |
| System | `/cgi-bin/logs.sh` | `logs.sh` | none | Show lighttpd error/access logs. | HTML log output. |
| System | `/cgi-bin/memstats.sh/<pid>/<return>` | `memstats.sh` | PATH_INFO pid or `fp`; return path. | Show `/proc/<pid>/maps` and `smaps`. | HTML memory details. |
| System | `/cgi-bin/memstats/<pid>/<return>` | `memstats` | PATH_INFO pid or `fp`; return path. | Same as `memstats.sh`. | HTML memory details. |
| Display | `/cgi-bin/message.sh?<text>` | `message.sh` | Raw query text. | Write text to `lighty/html/msg.txt`. | Text response confirming message. |
| Display | `/cgi-bin/msghdr.sh` | `msghdr.sh` | none | Return `msg.txt`, uptime, and free. | Text/HTML snippet. |
| Media Playback | `/cgi-bin/player.sh` | `player.sh` | none | Render web player UI using `chum.js`. | HTML controls for streams, stop, volume. |
| Widgets | `/cgi-bin/profiles.sh?<id>` | `profiles.sh` | id parsed from query. | Return `xml/profiles/profiles<ID>` or `profiles0`. | Profile XML. |
| Media Playback | `/cgi-bin/randomshuffler.sh` | `randomshuffler.sh` | none | List `/mnt/usb/music/*.mp3` in random order. | M3U-like path list. |
| System | `/cgi-bin/readme.sh` | `readme.sh` | none | Show Zurk README. | HTML README output. |
| Media Playback | `/cgi-bin/save_streams.sh?<xml>` | `save_streams.sh` | Raw stream XML. | Backup and overwrite `/psp/url_streams`. | Updates stream config. |
| Radio | `/cgi-bin/search.sh?<term>` | `search.sh` | Search term after first character. | Search local Shoutcast list. | `<stationlist>` XML. |
| Widgets | `/cgi-bin/show.sh?<id>` | `show.sh` | id parsed from query. | Return `xapis/profile/show/<id>` or `0`. | xAPI profile XML. |
| TTS | `/cgi-bin/speak.pl` | `speak.pl` | none, or `action=time&time=HH:MM`, or `action=say&words=text`, or `action=policy`. | Speak time/text or return Flash policy. | `done=true` or policy XML. |
| TTS | `/cgi-bin/speak` | `speak` | Same as `speak.pl`. | Duplicate TTS endpoint. | Same as `speak.pl`. |
| System | `/cgi-bin/ssh.sh` | `ssh.sh` | none | Attempts SSH control via service scripts. | Script prints `SSH cannot be enabled`; may be ineffective. |
| System | `/cgi-bin/sync.sh` | `sync.sh` | none | Run `sync`. | HTML says sync completed. |
| System | `/cgi-bin/top.sh` | `top.sh` | none | Show top, uptime, free, `/tmp` usage, interfaces. | Auto-refreshing HTML diagnostics. |
| Radio | `/cgi-bin/tune.sh?<query>` | `tune.sh` | Query transformed by stripping first 3 characters. | Return `chumcast/xshow_<id>`. | xshow content. |
| Network | `/cgi-bin/wifi.sh` | `wifi.sh` | none | Show `iwconfig` and `/proc/net/wireless`. | Auto-refreshing HTML WiFi stats. |
| Network | `/cgi-bin/wifi` | `wifi` | none | Same as `wifi.sh`. | Auto-refreshing HTML WiFi stats. |
| Brightness | `/cgi-bin/zmote_on.sh` | `zmote_on.sh` | none | Send `NightMode on` Flash event. | Night mode on event fired. |
| Brightness | `/cgi-bin/zmote_off.sh` | `zmote_off.sh` | none | Send `NightMode off` Flash event. | Night mode off event fired. |
| Media Playback | `/cgi-bin/zmote_play.sh?<url-or-path>` | `zmote_play.sh` | Raw query URL/path. | Send `UserPlayer play` Flash event. | URL/path playback starts if supported. |
| Media Playback | `/cgi-bin/zmote_playloop.sh?<url-or-path>` | `zmote_playloop.sh` | Raw query URL/path. | Send `UserPlayer playLoop` Flash event. | URL/path loops if supported. |
| Widgets | `/cgi-bin/pandora.sh` | `pandora.sh` | none | Copy `hosts.pandora` to active hosts file. | Switches hosts toward Chumby/Pandora infrastructure. |
| Widgets | `/cgi-bin/pandora-offline.sh` | `pandora-offline.sh` | none | Copy `hosts.offline` to active hosts file. | Switches hosts toward offline infrastructure. |

### Custom CGI Scripts

| Category | URL | Script | Parameters | Purpose | Expected result |
| --- | --- | --- | --- | --- | --- |
| Widgets | `/cgi-bin/custom/changewidget.sh` | `changewidget.sh` | none | Send `WidgetPlayer nextWidget`. | Next widget event fired. |
| Brightness | `/cgi-bin/custom/dim.sh` | `dim.sh` | none | Set dimlevel normal then dim. | Display dims. |
| Brightness | `/cgi-bin/custom/off.sh` | `off.sh` | none | Set dimlevel off. | Display turns off. |
| Brightness | `/cgi-bin/custom/setbrightness.sh?<0-100>` | `setbrightness.sh` | Raw brightness value. | Write day and night brightness files. | Response says brightness set; effect may require reboot per UI note. |
| Brightness | `/cgi-bin/custom/setday.sh?<0-100>` | `setday.sh` | Raw brightness value. | Write day brightness file. | Response says brightness set; post reboot per UI note. |
| Brightness | `/cgi-bin/custom/setnight.sh?<0-100>` | `setnight.sh` | Raw brightness value. | Write night brightness file. | Response says brightness set; post reboot per UI note. |
| Volume | `/cgi-bin/custom/setvol.sh?<0-100>` | `setvol.sh` | Raw volume value. | Send `MusicPlayer setVolume` Flash event. | Volume changes. |
| Volume | `/cgi-bin/custom/setmute.sh` | `setmute.sh` | none. | Send `MusicPlayer setMute` with comment `on`. | Mutes audio. |
| Radio | `/cgi-bin/custom/multistreams.sh?kexp` | `multistreams.sh` | `kexp`, `kuow`, `indiepop`, `doomed`, `groovesalad`, or `stop`. | Play predefined stream or stop. | Stream starts or stops. |
| Radio | `/cgi-bin/custom/shoutcast.sh` | `shoutcast.sh` | none | Play hardcoded KEXP stream. | KEXP stream starts. |
| Radio | `/cgi-bin/custom/somafm.sh?<station>` | `somafm.sh` | SomaFM station id. | Download SomaFM PLS, extract File1, play stream. | Stream starts if network and station work. |
| System | `/cgi-bin/custom/ssh.sh` | `ssh.sh` | none | Start `/sbin/sshd`. | SSH enabled. |
| System | `/cgi-bin/custom/sshoff.sh` | `sshoff.sh` | none | `killall sshd` and `sync`. | SSH disabled. |
| Network | `/cgi-bin/custom/traceroute.sh` | `traceroute.sh` | none | Run `traceroute www.google.com`. | Text traceroute output. |
| Misc | `/cgi-bin/custom/index.sh` | `index.sh` | none | Render custom control page with example links. | HTML control page. |

### Chumote CGI Scripts

| Category | URL | Script | Parameters | Purpose | Expected result |
| --- | --- | --- | --- | --- | --- |
| Misc | `/cgi-bin/chumote/index.cgi` | `index.cgi` | none | Render Chumote main remote control UI. | HTML with screen, widget, audio, display controls. |
| Misc | `/cgi-bin/chumote/admin.cgi` | `admin.cgi` | none | Render Chumote admin page. | HTML admin page. |
| Radio | `/cgi-bin/chumote/radio.cgi` | `radio.cgi` | none | Render Chumote radio page. | HTML radio control page. |
| Media Playback | `/cgi-bin/chumote/podcasts.cgi` | `podcasts.cgi` | none | Render podcast controls. | HTML podcast page. |
| Display | `/cgi-bin/chumote/fb0` | `fb0` | optional cachebuster. | Capture framebuffer 0. | JPEG framebuffer image. |
| Display | `/cgi-bin/chumote/fb1` | `fb1` | optional cachebuster. | Capture framebuffer 1. | JPEG framebuffer image. |
| Widgets | `/cgi-bin/chumote/event.cgi?nextWidget` | `event.cgi` | command. | Send `WidgetPlayer nextWidget`. | Next widget. |
| Widgets | `/cgi-bin/chumote/event.cgi?prevWidget` | `event.cgi` | command. | Send `WidgetPlayer prevWidget`. | Previous widget. |
| Widgets | `/cgi-bin/chumote/event.cgi?reload` | `event.cgi` | command. | Send `WidgetPlayer reload`. | Reload widget. |
| Widgets | `/cgi-bin/chumote/event.cgi?shuffle` | `event.cgi` | command. | Send `WidgetPlayer shuffle`. | Shuffle widgets. |
| Media Playback | `/cgi-bin/chumote/event.cgi?stopMusic` | `event.cgi` | command. | Send `MusicPlayer stop`. | Stop music. |
| Volume | `/cgi-bin/chumote/event.cgi?setVolume0` | `event.cgi` | command. | Send `MusicPlayer setVolume 0`. | Volume 0. |
| Volume | `/cgi-bin/chumote/event.cgi?setVolume50` | `event.cgi` | command. | Send `MusicPlayer setVolume 50`. | Volume 50. |
| Volume | `/cgi-bin/chumote/event.cgi?setVolume100` | `event.cgi` | command. | Send `MusicPlayer setVolume 100`. | Volume 100. |
| Brightness | `/cgi-bin/chumote/event.cgi?sleep` | `event.cgi` | command. | Send `NightMode on`. | Sleep/night mode. |
| Brightness | `/cgi-bin/chumote/event.cgi?wake` | `event.cgi` | command. | Send `NightMode off`. | Wake/night mode off. |
| Brightness | `/cgi-bin/chumote/event.cgi?bright` | `event.cgi` | command. | Send `ScreenManager bright`. | Bright screen event. |
| Brightness | `/cgi-bin/chumote/event.cgi?dim` | `event.cgi` | command. | Send `ScreenManager dim`. | Dim screen event. |
| Brightness | `/cgi-bin/chumote/event.cgi?off` | `event.cgi` | command. | Send `ScreenManager off`. | Screen off event. |
| Audio | `/cgi-bin/chumote/event.cgi?stopAlarm` | `event.cgi` | command. | Send `AlarmPlayer stop`. | Stop alarm audio/player. |
| Radio | `/cgi-bin/chumote/event.cgi?fmradio1` through `fmradio7` | `event.cgi` | command. | Send `FMRadio preset` comments `0` through `6`. | FM preset selected. |
| Radio | `/cgi-bin/chumote/event.cgi?fmradiostop` | `event.cgi` | command. | Send `FMRadio stop`. | FM radio stops. |
| Radio | `/cgi-bin/chumote/event.cgi?fmradioscanup` | `event.cgi` | command. | Send `FMRadio scan up`. | FM scan up. |
| Radio | `/cgi-bin/chumote/event.cgi?fmradioscandown` | `event.cgi` | command. | Send `FMRadio scan down`. | FM scan down. |
| Radio | `/cgi-bin/chumote/event.cgi?freq=<frequency>` | `event.cgi` | `freq` command with value after `=`. | Send `FMRadio play` with frequency. | Tune requested FM frequency. |
| System | `/cgi-bin/chumote/control.cgi?cp_stop` | `control.cgi` | command. | Call `stop_control_panel`. | Stock Control Panel stops. |
| System | `/cgi-bin/chumote/control.cgi?reboot` | `control.cgi` | command. | Run `reboot`. | Device reboots. |
| Radio | `/cgi-bin/chumote/control.cgi?radiostop` | `control.cgi` | command. | Run `btplay stop`. | btplay stops. |
| Radio | `/cgi-bin/chumote/control.cgi?radio1` | `control.cgi` | command. | Run `btplay http://66.162.107.142/cpr1_lo`. | Stream starts. |
| Radio | `/cgi-bin/chumote/control.cgi?radio2` | `control.cgi` | command. | Run `btplay http://66.162.107.142/cpr3_lo`. | Stream starts. |
| Radio | `/cgi-bin/chumote/control.cgi?radio3` | `control.cgi` | command. | Run `btplay http://66.162.107.142/cpr2_lo`. | Stream starts. |
| Media Playback | `/cgi-bin/chumote/control.cgi?playpodcast&<url>` | `control.cgi` | command plus URL as second `&` field. | Run `btplay <url>`. | Podcast/audio URL plays. |
| Media Playback | `/cgi-bin/chumote/control.cgi?podscan` | `control.cgi` | command. | Run `bashpodder.shell`, sleep 20. | Podcast scan starts. |
| Radio | `/cgi-bin/chumote/streams?<name>` | `streams` | `kexp`, `kuow`, `indiepop`, `doomed`, `groovesalad`, `stop`. | Play predefined stream or stop. | Stream starts/stops. |
| Radio | `/cgi-bin/chumote/status.xml` | `status.xml` | none | Static/example FM status XML. | XML status. |
| Radio | `/cgi-bin/chumote/fmstatus.xml` | `fmstatus.xml` | none | Static/example FM status XML. | XML status. |

## Endpoint Classification Summary

| Category | Strong candidates | Notes |
| --- | --- | --- |
| Display | `/cgi-bin/message.sh`, `/cgi-bin/fb.sh`, `/cgi-bin/fb1.sh`, `/cgi-bin/chumote/event.cgi?off|dim|bright` | Text display depends on message widget/profile being visible. Framebuffer endpoints are read-only capture. |
| Audio | `/cgi-bin/chumote/event.cgi?stopAlarm`, volume endpoints | Alarm stop event exists but HA-Chumby alarm logic should remain in Home Assistant for MVP. |
| TTS | `/cgi-bin/speak.pl?action=say&words=...` | Directly reusable. |
| Radio | `/cgi-bin/custom/multistreams.sh`, `/cgi-bin/custom/somafm.sh`, `/cgi-bin/chumote/streams`, `/cgi-bin/chumote/control.cgi?radio*` | Predefined endpoints work; arbitrary stream playback is better via `zmote_play.sh` or Chumote playpodcast. |
| Media Playback | `/cgi-bin/zmote_play.sh`, `/cgi-bin/zmote_playloop.sh`, `/cgi-bin/chumote/control.cgi?playpodcast&...`, `/music.m3u` | Directly useful for wake MP3/radio. |
| Volume | `/cgi-bin/custom/setvol.sh`, `/cgi-bin/chumote/event.cgi?setVolume*`, `/cgi-bin/custom/setmute.sh` | Directly reusable. |
| Brightness | `/cgi-bin/custom/off.sh`, `/cgi-bin/custom/dim.sh`, `/cgi-bin/custom/setbrightness.sh`, Chumote bright/dim/off | Directly reusable with hardware validation. |
| Widgets | profile/show endpoints, widget navigation events, Pandora/offline hosts switch | Useful for stock widget behavior, not primary MVP. |
| System | sync, logs, top, dmesg, memstats, ssh, Chumote admin controls | Useful for support/diagnostics. |
| Network | wifi, traceroute, Shoutcast/SomaFM lookups | Useful for diagnostics and stream discovery. |
| Misc | helloworld language tests, index/control pages | Useful as firmware capability proof, not MVP. |

## Recommended MVP Control Surface

Prefer these existing endpoints for the MVP:

| MVP action | Existing endpoint to call | Reason |
| --- | --- | --- |
| Speak wake phrase | `/cgi-bin/speak.pl?action=say&words=<url-encoded text>` | Direct TTS endpoint, no custom TTS needed. |
| Set wake volume | `/cgi-bin/custom/setvol.sh?<0-100>` | Arbitrary 0-100 volume endpoint. |
| Play wake music MP3/radio URL | `/cgi-bin/zmote_play.sh?<url>` | Accepts arbitrary URL/path as query string and sends stock `UserPlayer play`. |
| Loop local wake audio | `/cgi-bin/zmote_playloop.sh?/mnt/usb/music/<file>.mp3` | Existing loop playback event. |
| Stop wake music | `/cgi-bin/chumote/event.cgi?stopMusic` or `/cgi-bin/custom/multistreams.sh?stop` | Existing stop event. |
| Show short message | `/cgi-bin/message.sh?<text>` | Existing message file update; requires a widget/profile that reads `msg.txt`. |
| Turn display off | `/cgi-bin/custom/off.sh` or `/cgi-bin/chumote/event.cgi?off` | Existing dimlevel or ScreenManager event. |
| Dim display | `/cgi-bin/custom/dim.sh` or `/cgi-bin/chumote/event.cgi?dim` | Existing dimlevel or ScreenManager event. |
| Capture display for validation | `/cgi-bin/fb.sh` | Existing JPEG framebuffer capture. |
| Flush USB changes | `/cgi-bin/sync.sh` | Existing sync endpoint. |

## Verified Facts

| Fact | Source |
| --- | --- |
| Zurk Offline Firmware v21 exposes a local web control page from the Chumby IP address. | `E:\README.TXT`, `E:\lighty\html\index.html` |
| The web server document root is `/mnt/usb/lighty/html`. | `E:\lighty\lighttpd.conf` |
| Requests under `/cgi-bin/` are served from `/mnt/usb/lighty/cgi-bin/`. | `E:\lighty\lighttpd.conf` |
| Shell CGI files use `/bin/sh`; Perl, PHP, and Python CGI files use interpreters bundled on the USB stick. | `E:\lighty\lighttpd.conf` |
| TTS is available through `speak.pl` using the bundled TalkingChumby Flite binaries. | `E:\lighty\cgi-bin\speak.pl`, `E:\README.TXT` |
| Arbitrary UserPlayer play and playLoop events are exposed through `zmote_play.sh` and `zmote_playloop.sh`. | `E:\lighty\cgi-bin\zmote_play.sh`, `E:\lighty\cgi-bin\zmote_playloop.sh`, `E:\lighty\html\index.html` |
| Music stop and fixed volume events are exposed through Chumote `event.cgi`. | `E:\lighty\cgi-bin\chumote\event.cgi`, `E:\lighty\cgi-bin\chumote\index.cgi` |
| Arbitrary 0-100 music volume is exposed through `custom/setvol.sh`. | `E:\lighty\cgi-bin\custom\setvol.sh`, `E:\lighty\html\index.html` |
| Brightness and screen control commands are exposed through `custom/off.sh`, `custom/dim.sh`, and Chumote `event.cgi`. | `E:\lighty\cgi-bin\custom\off.sh`, `E:\lighty\cgi-bin\custom\dim.sh`, `E:\lighty\cgi-bin\chumote\event.cgi`, `E:\lighty\html\index.html` |
| Framebuffer capture endpoints are exposed as JPEG CGI responses. | `E:\lighty\cgi-bin\fb.sh`, `E:\lighty\cgi-bin\fb1.sh`, `E:\lighty\cgi-bin\chumote\fb0`, `E:\lighty\cgi-bin\chumote\fb1` |

## Assumptions

No project architecture assumptions are required to describe the discovered firmware endpoints in this document. MVP recommendations are limited to observed endpoint behavior from the inspected USB files listed in the source columns above.

## Open Questions

| Question | Why it remains open | Source context |
| --- | --- | --- |
| Does `zmote_play.sh` reliably play every MP3 URL and local `/mnt/usb/music/*.mp3` path on Chumby Classic hardware? | The script emits a Flash player event, but playback success depends on codecs, network access, and stock player behavior that must be validated on hardware. | `E:\lighty\cgi-bin\zmote_play.sh`, `E:\lighty\html\index.html` |
| Does `message.sh` display text immediately with the default active profile? | The script writes `msg.txt`; immediate on-screen display depends on a widget/profile that reads that file. | `E:\lighty\cgi-bin\message.sh`, `E:\README.TXT` |
| Which screen-control endpoint is safest for night operation: direct `/proc/sys/sense1/dimlevel` writes or `ScreenManager` events? | Both mechanisms exist; hardware validation is needed to compare persistence and side effects. | `E:\lighty\cgi-bin\custom\off.sh`, `E:\lighty\cgi-bin\custom\dim.sh`, `E:\lighty\cgi-bin\chumote\event.cgi` |
| Can the mute state be cleared through an existing endpoint? | `custom/setmute.sh` only sends `setMute` with `comment="on"`; no matching unmute script was found in the inspected CGI tree. | `E:\lighty\cgi-bin\custom\setmute.sh`, `E:\lighty\cgi-bin\custom\index.sh` |
| Is `control.cgi?cp_restart` functional from the Chumote UI? | `admin.cgi` links to `cp_restart`, while `control.cgi` contains a `cd_restart` case. | `E:\lighty\cgi-bin\chumote\admin.cgi`, `E:\lighty\cgi-bin\chumote\control.cgi` |
| Which endpoints remain available when the HA-Chumby foreground boot loop keeps stock UI control from resuming? | Sprint 4 changed boot persistence; endpoint availability after that startup mode must be validated on real hardware. | `docs\installation\BOOT_PERSISTENCE.md`, `E:\lighty\lighttpd.conf` |
