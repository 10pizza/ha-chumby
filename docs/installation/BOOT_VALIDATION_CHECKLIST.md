# Boot Validation Checklist

Use this checklist on real Chumby Classic / beanbag HW 3.7 hardware after preparing a Sprint 4 USB stick.

## Hardware

| Done | Check |
| --- | --- |
| [ ] | Device is Chumby Classic / beanbag HW 3.7. |
| [ ] | USB stick is prepared with the current `installer/prepare_usb.ps1`. |
| [ ] | USB stick contains `/debugchumby`. |
| [ ] | USB stick contains `/ha-chumby/start.sh`. |
| [ ] | USB stick contains `/ha-chumby/boot-screen.rgb565`. |
| [ ] | USB stick remains inserted for persistence validation. |
| [ ] | Power supply is stable. |

## Boot Proof

| Done | Check |
| --- | --- |
| [ ] | Power on with USB inserted. |
| [ ] | Screen displays `HA-Chumby`. |
| [ ] | Screen displays `Boot successful`. |
| [ ] | Screen displays `Version 0.1`. |
| [ ] | Screen remains on the HA-Chumby boot screen for at least 60 seconds. |
| [ ] | Stock setup/calibration flow does not immediately take over the display. |
| [ ] | No Home Assistant integration starts. |
| [ ] | No alarm feature starts. |
| [ ] | No new networking behavior is introduced by HA-Chumby. |

## Log Proof

| Done | Check |
| --- | --- |
| [ ] | `/tmp/ha-chumby.log` exists. |
| [ ] | Log contains `debugchumby: starting HA-Chumby USB entrypoint`. |
| [ ] | Log contains `debugchumby: execing HA-Chumby app in foreground`. |
| [ ] | Log contains `start.sh: starting HA-Chumby persistent boot screen`. |
| [ ] | Log contains `start.sh: initial boot screen written`. |
| [ ] | Log contains `start.sh: entering persistent foreground redraw loop`. |
| [ ] | If available, record whether `stop_control_panel` succeeded or returned non-zero. |

## Reboot Repeatability

| Done | Check |
| --- | --- |
| [ ] | Power off with USB still inserted. |
| [ ] | Power on with same USB stick. |
| [ ] | Boot confirmation appears again. |
| [ ] | Boot confirmation remains visible for at least 60 seconds. |
| [ ] | Repeat for three successful cycles. |

## No Internal Flash Modification Evidence

| Done | Check |
| --- | --- |
| [ ] | Do not run `debugchumby.zurk-original`. |
| [ ] | Do not run any official firmware installer menu. |
| [ ] | Power off. |
| [ ] | Remove USB stick. |
| [ ] | Power on without USB stick. |
| [ ] | Device returns to previous non-HA-Chumby behavior. |
| [ ] | Record whether any persistent settings changed. |
| [ ] | Reinsert USB and confirm HA-Chumby behavior returns. |

## Failure Notes

Record:

- Date and time.
- Device label and hardware revision.
- Firmware state before test.
- USB brand and capacity.
- Whether `/tmp/ha-chumby.log` was readable.
- Last visible screen before failure.
- Whether stock UI appeared after HA-Chumby.
- Whether removing USB restored original behavior.
