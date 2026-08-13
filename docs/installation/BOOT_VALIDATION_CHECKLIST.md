# Boot Validation Checklist

Use this checklist on real Chumby Classic / beanbag HW 3.7 hardware after preparing a Sprint 3 USB stick.

## Hardware

| Done | Check |
| --- | --- |
| [ ] | Device is Chumby Classic / beanbag HW 3.7. |
| [ ] | USB stick is prepared with `installer/prepare_usb.ps1`. |
| [ ] | USB stick remains inserted for every validation boot. |
| [ ] | Power supply is stable. |

## Boot Proof

| Done | Check |
| --- | --- |
| [ ] | Power on with USB inserted. |
| [ ] | Screen displays `HA-Chumby`. |
| [ ] | Screen displays `Boot successful`. |
| [ ] | Screen displays `Version 0.1`. |
| [ ] | No Home Assistant integration starts. |
| [ ] | No alarm feature starts. |

## Reboot Repeatability

| Done | Check |
| --- | --- |
| [ ] | Power off. |
| [ ] | Power on with same USB stick. |
| [ ] | Boot confirmation appears again. |
| [ ] | Repeat for three successful cycles. |

## No Internal Flash Modification Evidence

| Done | Check |
| --- | --- |
| [ ] | Do not run `debugchumby.zurk-original`. |
| [ ] | Remove USB stick after power-off. |
| [ ] | Power on without USB stick. |
| [ ] | Device returns to previous non-HA-Chumby behavior. |
| [ ] | Record any persistent setting changes. |

## Notes

Record date, device label, firmware state before test, USB brand/capacity, and observed screen behavior.
