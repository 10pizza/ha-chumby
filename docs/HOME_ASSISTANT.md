# Home Assistant MVP Integration

Status: Sprint 7 Home Assistant MVP integration.

This sprint proves that Home Assistant can control HA-Chumby through existing Zurk Offline Firmware HTTP endpoints. It does not create a custom Chumby REST server, custom Home Assistant integration, MQTT bridge, AppDaemon app, Python service, or replacement media player.

## Source Decisions

| Decision | Source |
| --- | --- |
| Use Home Assistant `rest_command` actions for HTTP calls. | Home Assistant RESTful Command documentation: https://www.home-assistant.io/integrations/rest_command/ |
| Package the configuration in one YAML file. | Home Assistant package documentation: https://www.home-assistant.io/docs/configuration/packages/ |
| Use standard dashboard cards and `perform-action` actions. | Home Assistant button card and dashboard action documentation: https://www.home-assistant.io/dashboards/button/ and https://www.home-assistant.io/dashboards/actions |
| Reuse Zurk firmware endpoints for TTS, volume, playback, stop, dim, and off. | `docs/API.md`, `docs/MVP_MAPPING.md` |

## Files

| Repository file | Purpose |
| --- | --- |
| `homeassistant/packages/ha_chumby.yaml` | Package containing helpers, REST commands, and wrapper scripts. |
| `homeassistant/dashboards/ha_chumby_dashboard.yaml` | Example dashboard YAML using standard Home Assistant cards only. |
| `docs/HA_VALIDATION.md` | Manual hardware validation checklist. |

## Install The Package

1. In your Home Assistant configuration directory, create a `packages` directory if it does not already exist.
2. Copy `homeassistant/packages/ha_chumby.yaml` from this repository to `/config/packages/ha_chumby.yaml` in Home Assistant.
3. Enable packages in `/config/configuration.yaml`:

```yaml
homeassistant:
  packages: !include_dir_named packages
```

4. Restart Home Assistant after changing `configuration.yaml` or adding the package file.
5. Open Settings, Devices & services, Helpers, or Developer tools, States, and confirm these helper entities exist:

```text
input_text.ha_chumby_base_url
input_text.ha_chumby_speak_text
input_text.ha_chumby_play_url
input_number.ha_chumby_volume
```

6. Set `input_text.ha_chumby_base_url` to the Chumby web server base URL. Examples:

```text
http://chumby.local
http://192.168.1.42
```

Do not add a trailing slash.

## REST Commands

| Home Assistant action | Zurk endpoint | Purpose |
| --- | --- | --- |
| `rest_command.ha_chumby_speak` | `/cgi-bin/speak.pl?action=say&words=<text>` | Speak text with the existing Zurk TTS path. |
| `rest_command.ha_chumby_set_volume` | `/cgi-bin/custom/setvol.sh?<0-100>` | Set Chumby music volume. |
| `rest_command.ha_chumby_play_url` | `/cgi-bin/zmote_play.sh?<url>` | Play an MP3 or stream URL through the stock player event path. |
| `rest_command.ha_chumby_stop` | `/cgi-bin/chumote/event.cgi?stopMusic` | Stop music playback. |
| `rest_command.ha_chumby_screen_off` | `/cgi-bin/custom/off.sh` | Turn the display off through the existing firmware script. |
| `rest_command.ha_chumby_screen_dim` | `/cgi-bin/custom/dim.sh` | Dim the display through the existing firmware script. |

## Scripts

| Home Assistant script | Purpose |
| --- | --- |
| `script.chumby_speak` | Speak the provided `words` field or the helper text. |
| `script.chumby_set_volume` | Set the provided `volume` field or the helper volume. |
| `script.chumby_play_url` | Play the provided `media_url` field or the helper URL. |
| `script.chumby_play_radio` | Play the helper URL as the current radio/stream source. |
| `script.chumby_stop` | Stop playback. |
| `script.chumby_screen_off` | Turn the screen off. |
| `script.chumby_screen_dim` | Dim the screen. |
| `script.chumby_good_morning` | Set volume, speak the helper text, wait briefly, then play the helper stream. |

## Example Calls

Call from Developer tools, Actions.

Speak text:

```yaml
action: script.chumby_speak
data:
  words: "Good morning Luka"
```

Set volume:

```yaml
action: script.chumby_set_volume
data:
  volume: 50
```

Play stream:

```yaml
action: script.chumby_play_url
data:
  media_url: "http://ice1.somafm.com/groovesalad-128-mp3"
```

Stop playback:

```yaml
action: script.chumby_stop
```

Run the simple morning sequence:

```yaml
action: script.chumby_good_morning
```

## Dashboard

The example dashboard is in `homeassistant/dashboards/ha_chumby_dashboard.yaml`.

To use it manually:

1. Open a Home Assistant dashboard.
2. Choose Edit dashboard.
3. Open the raw configuration editor.
4. Copy the YAML from `homeassistant/dashboards/ha_chumby_dashboard.yaml`, or copy individual cards into an existing dashboard.

The dashboard uses standard Home Assistant cards only: `entities`, `grid`, and `button`.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Script runs but nothing happens | Confirm `input_text.ha_chumby_base_url` points to the Chumby IP or hostname and starts with `http://`. |
| Home Assistant cannot load the package | Confirm `configuration.yaml` uses `homeassistant: packages: !include_dir_named packages` and that the file extension is `.yaml`. |
| Speak text fails | Test `http://<chumby-ip>/cgi-bin/speak.pl?action=say&words=hello` directly in a browser. |
| Volume does not change | Test `http://<chumby-ip>/cgi-bin/custom/setvol.sh?50` directly in a browser. |
| Stream does not play | Test a simple MP3 stream URL first; codec and stream compatibility are stock firmware behavior and require hardware validation. |
| Stop does not work | Test `http://<chumby-ip>/cgi-bin/chumote/event.cgi?stopMusic` directly in a browser. |
| Screen commands do not behave as expected | Compare `/cgi-bin/custom/off.sh`, `/cgi-bin/custom/dim.sh`, and the Chumote ScreenManager events documented in `docs/API.md`. |

## Non-Goals

This package intentionally does not include:

- A custom Home Assistant integration.
- MQTT.
- AppDaemon.
- A service running on the Chumby.
- Python on the Chumby.
- A replacement media player.
- A replacement TTS engine.
