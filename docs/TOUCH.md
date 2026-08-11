# Touch Reverse Engineering Notes

Scope: Chumby Classic / Ironforge touchscreen hardware, raw coordinate paths,
and calibration/recovery behavior; the Chumby Wiki identifies Chumby Classic as
Ironforge. [[source](https://wiki.chumby.com/index.php?title=Devices)] Each
finding is linked to a source. Unverified details are listed under
[Unknowns](#unknowns).

## Sourced Findings

| Area | Finding | Source |
| --- | --- | --- |
| Touch hardware | Chumby Classic hardware lists a DataImage 320 x 240, 16 bpp TFT display with touchscreen. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| Touch controller | Chumby Classic hardware lists a Texas Instruments TSC2100 programmable touchscreen controller. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| `/dev/ts` purpose | The Chumby `/dev` page describes `/dev/ts` as faster and directly connected with the touchscreen driver. | [Chumby Wiki: Chumby device settings information on /dev](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fdev) |
| `/dev/ts` implementation reference | The Chumby `/dev` page includes a C example for reading `/dev/ts`. | [Chumby Wiki: Chumby device settings information on /dev](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fdev) |
| `/proc/chumby/touchscreen` namespace | The Chumby `/proc` page documents a `/proc/chumby/touchscreen` namespace. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Touch click state | `/proc/chumby/touchscreen/touchclick` contains `1` when touchscreen click is enabled and `0` when disabled. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Touch polling interval | `/proc/chumby/touchscreen/timer-interval` shows when touchscreen coordinate and pressure data are polled by the driver. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Touch polling default example | The `/proc` page shows `1000 milliseconds` as a `timer-interval` example and labels `1000` as the default value. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Touch coordinates path | `/proc/chumby/touchscreen/coordinates` shows recent touchscreen events. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Touch event types | The `/proc` page describes `pen-up` and `pen-down` events in `/proc/chumby/touchscreen/coordinates`. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Pen-up values | The `/proc` page says pen-up is logged when touch stops and its coordinates are always `0`. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Pen-down values | The `/proc` page says pen-down is continuously logged while touching and includes x, y, and pressure. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Touch enable path | `/proc/chumby/touchscreen/enable` contains `1` when the touchscreen is enabled and `0` when disabled. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Touch disable command | The `/proc` page documents disabling the touchscreen with `echo 0 > /proc/chumby/touchscreen/enable`. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Touch click command | The Chumby tricks page documents enabling touch click with `echo 1 > /proc/chumby/touchscreen/touchclick` and disabling it with `echo 0 > /proc/chumby/touchscreen/touchclick`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Make_your_chumby_click_when_you_touch_the_screen) |
| Calibration recovery | If touchscreen calibration is unusable, a USB file named `ts_settings` can restore calibration well enough to navigate the Control Panel calibration section. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Screwed_up_your_touchscreen_calibration.3F) |
| Flash raw coordinates | Ironforge widget documentation says raw touchscreen coordinates are available through ASnative calls. | [Chumby Wiki: Developing Widgets for Chumby: Sensor Access](https://wiki.chumby.com/index.php?title=Developing_Widgets_for_Chumby%3A_Sensor_Access) |
| Flash input model | Ironforge widget documentation says the touchscreen input system only emits mouseMove events while mouseDown. | [Chumby Wiki: Developing widgets for chumby](https://wiki.chumby.com/index.php?title=Developing_widgets_for_chumby) |

## Unknowns

- Exact binary structure emitted by `/dev/ts`.
- Exact coordinate transform used by the Control Panel calibration.
- Exact storage path for persistent calibration on HW 3.7.
- Exact raw coordinate range for a specific HW 3.7 unit.
- Exact pressure threshold used for touch classification.
- Whether the stock kernel exposes standard Linux input event devices for touch.
- Whether multitouch is impossible at the controller level or only unsupported in software.
