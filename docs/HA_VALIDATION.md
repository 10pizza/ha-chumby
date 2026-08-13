# Home Assistant Hardware Validation

Status: Sprint 7 manual validation checklist.

This document defines the manual test plan for the Home Assistant package in `homeassistant/packages/ha_chumby.yaml`. Do not mark a command as successful until it has been run against real Chumby Classic hardware booted with the HA-Chumby USB overlay and Zurk Offline Firmware.

## Preconditions

| Item | Required state | Evidence source |
| --- | --- | --- |
| Chumby is booted from USB | HA-Chumby USB overlay is active and internal flash has not been modified. | `docs/installation/PREPARE_USB.md`, `docs/installation/BOOT_PERSISTENCE.md` |
| Zurk web server is reachable | `http://<chumby-ip>/` opens the Zurk web control page. | `docs/API.md`, `E:\README.TXT`, `E:\lighty\html\index.html` |
| Home Assistant package is loaded | `script.chumby_speak`, `script.chumby_set_volume`, `script.chumby_play_url`, and `script.chumby_stop` exist. | `homeassistant/packages/ha_chumby.yaml` |
| Base URL helper is configured | `input_text.ha_chumby_base_url` contains `http://<chumby-ip>` with no trailing slash. | `homeassistant/packages/ha_chumby.yaml` |

## Validation Record

| Field | Value |
| --- | --- |
| Date tested | Not tested yet |
| Tester | Not tested yet |
| Chumby model | Chumby Classic beanbag HW 3.7 |
| Zurk firmware package | Not recorded yet |
| Chumby IP/hostname | Not recorded yet |
| Home Assistant Core version | Not recorded yet |

## REST Command Tests

Run each test from Home Assistant Developer tools, Actions. Record the result in the final column.

| Test | Home Assistant action | Test data | Expected hardware result | Expected HTTP/action result | Status |
| --- | --- | --- | --- | --- | --- |
| Speak arbitrary text | `rest_command.ha_chumby_speak` | `words: "Good morning Luka"` | Chumby speaks the phrase through the existing Zurk TTS engine. | Action completes without Home Assistant error. `speak.pl` is expected to return `done=true` based on Sprint 5 source inspection. | Not tested |
| Set volume to 30 | `rest_command.ha_chumby_set_volume` | `volume: 30` | Subsequent audio plays quieter than high-volume tests. | Action completes without Home Assistant error. `setvol.sh` is expected to return a volume-set text response based on Sprint 5 source inspection. | Not tested |
| Set volume to 70 | `rest_command.ha_chumby_set_volume` | `volume: 70` | Subsequent audio plays louder than the volume-30 test. | Action completes without Home Assistant error. | Not tested |
| Play MP3 or radio stream | `rest_command.ha_chumby_play_url` | `media_url: "http://ice1.somafm.com/groovesalad-128-mp3"` | Chumby starts playing the stream if the stock player supports the URL and codec. | Action completes without Home Assistant error. | Not tested |
| Stop playback | `rest_command.ha_chumby_stop` | none | Chumby stops current music playback. | Action completes without Home Assistant error. | Not tested |
| Screen off | `rest_command.ha_chumby_screen_off` | none | Chumby display turns off. | Action completes without Home Assistant error. | Not tested |
| Screen dim | `rest_command.ha_chumby_screen_dim` | none | Chumby display dims or cycles dim state according to the existing Zurk script behavior. | Action completes without Home Assistant error. | Not tested |

## Script Wrapper Tests

| Test | Home Assistant action | Expected result | Status |
| --- | --- | --- | --- |
| Speak wrapper | `script.chumby_speak` | Same result as `rest_command.ha_chumby_speak`. | Not tested |
| Volume wrapper | `script.chumby_set_volume` | Helper value and Chumby volume are set to the requested value. | Not tested |
| Play URL wrapper | `script.chumby_play_url` | Same result as `rest_command.ha_chumby_play_url`. | Not tested |
| Play radio wrapper | `script.chumby_play_radio` | Chumby plays the URL stored in `input_text.ha_chumby_play_url`. | Not tested |
| Stop wrapper | `script.chumby_stop` | Same result as `rest_command.ha_chumby_stop`. | Not tested |
| Screen off wrapper | `script.chumby_screen_off` | Same result as `rest_command.ha_chumby_screen_off`. | Not tested |
| Screen dim wrapper | `script.chumby_screen_dim` | Same result as `rest_command.ha_chumby_screen_dim`. | Not tested |
| Good morning wrapper | `script.chumby_good_morning` | Chumby sets volume, speaks the helper text, waits briefly, then starts the helper stream. | Not tested |

## Direct Browser Cross-Checks

Use these only to isolate whether a problem is in Home Assistant or the Chumby firmware endpoint.

| Firmware endpoint | Expected result | Status |
| --- | --- | --- |
| `http://<chumby-ip>/cgi-bin/speak.pl?action=say&words=hello` | Chumby speaks `hello`. | Not tested |
| `http://<chumby-ip>/cgi-bin/custom/setvol.sh?50` | Volume is set to 50. | Not tested |
| `http://<chumby-ip>/cgi-bin/zmote_play.sh?<stream-url>` | Stream starts if supported by firmware. | Not tested |
| `http://<chumby-ip>/cgi-bin/chumote/event.cgi?stopMusic` | Playback stops. | Not tested |
| `http://<chumby-ip>/cgi-bin/custom/off.sh` | Display turns off. | Not tested |
| `http://<chumby-ip>/cgi-bin/custom/dim.sh` | Display dims or cycles according to script behavior. | Not tested |

## Failure Notes

Record failures here during hardware testing.

| Command | Observed result | Suspected layer | Follow-up |
| --- | --- | --- | --- |
| Not tested yet | Not tested yet | Not tested yet | Not tested yet |

## Validation Rule

A command may be marked successful only after it has been tested from Home Assistant against real hardware. Source inspection alone is not success.
