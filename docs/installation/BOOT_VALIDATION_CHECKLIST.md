# Boot Validation Checklist

Use this checklist on real Chumby Classic / beanbag HW 3.7 hardware after preparing a current HA-Chumby USB stick.

## Hardware

| Done | Check |
| --- | --- |
| [ ] | Device is Chumby Classic / beanbag HW 3.7. |
| [ ] | USB stick is prepared with the current `installer/prepare_usb.ps1`. |
| [ ] | USB stick contains `/debugchumby`. |
| [ ] | USB stick contains `/debugchumby.zurk-original`. |
| [ ] | USB stick contains `/ha-chumby/start.sh`. |
| [ ] | USB stick contains `/ha-chumby/boot-screen.rgb565`. |
| [ ] | USB stick contains `/psp/firsttime` with value `0`. |
| [ ] | USB stick contains `/psp/firsttime.zurk-original` when prepared from the Zurk archive. |
| [ ] | USB stick remains inserted for validation. |
| [ ] | Power supply is stable. |

## Boot And Hand-Off Proof

| Done | Check |
| --- | --- |
| [ ] | Power on with USB inserted. |
| [ ] | Screen briefly displays `HA-Chumby`. |
| [ ] | Screen briefly displays `Boot successful`. |
| [ ] | Screen briefly displays `Version 0.1`. |
| [ ] | Splash remains visible for approximately 2-3 seconds. |
| [ ] | HA-Chumby splash disappears without manual intervention. |
| [ ] | Original Chumby interface appears automatically. |
| [ ] | Touchscreen calibration wizard does not appear. |
| [ ] | Wi-Fi setup wizard does not appear. |
| [ ] | Widgets become active. |
| [ ] | No Home Assistant integration starts. |
| [ ] | No alarm feature starts. |
| [ ] | No internal firmware installer runs. |

## Runtime Control Proof

| Done | Check |
| --- | --- |
| [ ] | Chumote web interface is reachable. |
| [ ] | `event.cgi?wake` changes device state. |
| [ ] | `event.cgi?setVolume100` changes volume. |
| [ ] | Radio playback works through the original runtime. |
| [ ] | `speak.pl` is reachable if TTS is enabled by the restored Zurk runtime. |

## Log Proof

| Done | Check |
| --- | --- |
| [ ] | `/tmp/ha-chumby.log` exists during runtime if readable. |
| [ ] | `/mnt/usb/ha-chumby/boot-diagnostics.txt` exists on the USB stick. |
| [ ] | Log contains `debugchumby: starting HA-Chumby USB entrypoint`. |
| [ ] | Log contains `debugchumby: execing finite HA-Chumby startup overlay`. |
| [ ] | Log contains `start.sh: initial boot screen written`. |
| [ ] | Log contains `start.sh: sleeping 3 seconds before hand-off`. |
| [ ] | Log contains `start.sh: exiting HA-Chumby overlay so original Chumby startup can continue`. |
| [ ] | Log contains `configured-state marker detected`. |
| [ ] | Log records the Zurk startup exit code. |

## Reboot Repeatability

| Done | Check |
| --- | --- |
| [ ] | Power off with USB still inserted. |
| [ ] | Power on with same USB stick. |
| [ ] | HA-Chumby splash appears again. |
| [ ] | Original Chumby interface appears again after the splash. |
| [ ] | Repeat for three successful cycles. |

## No Internal Flash Modification Evidence

| Done | Check |
| --- | --- |
| [ ] | Confirm `debugchumby.zurk-original` is preserved on USB and runs only from HA-Chumby after the splash. |
| [ ] | Do not run any official firmware installer menu. |
| [ ] | Power off. |
| [ ] | Remove USB stick. |
| [ ] | Power on without USB stick. |
| [ ] | Device returns to previous non-HA-Chumby behavior. |
| [ ] | Record whether any persistent settings changed. |
| [ ] | Reinsert USB and confirm HA-Chumby behavior returns. |
| [ ] | Confirm `/mnt/usb/ha-chumby/boot-diagnostics.txt` shows no internal flash write operations from HA-Chumby. |

## Failure Notes

Record:

- Date and time.
- Device label and hardware revision.
- Firmware state before test.
- USB brand and capacity.
- Whether `/tmp/ha-chumby.log` was readable.
- Last visible screen before failure.
- Whether original UI appeared after HA-Chumby.
- Whether Chumote event commands affected the device.
- Whether removing USB restored original behavior.
