# Audio Reverse Engineering Notes

Scope: Chumby Classic / Ironforge audio hardware, exposed mixer controls, and
known software hooks; the Chumby Wiki identifies Chumby Classic as Ironforge.
[[source](https://wiki.chumby.com/index.php?title=Devices)] Each finding is
linked to a source. Unverified details are listed under [Unknowns](#unknowns).

## Sourced Findings

| Area | Finding | Source |
| --- | --- | --- |
| Audio controller | Chumby Classic hardware lists the Texas Instruments TSC2100 as a programmable touchscreen controller with stereo DAC. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| Speakers | Chumby Classic hardware lists 2 W stereo speakers with a headphone jack. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| Microphone | Chumby Classic hardware lists a built-in microphone. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| Device-table audio | The Chumby Classic device table lists `2x2W speakers`, a headphone jack, and microphone. | [Chumby Wiki: Devices](https://wiki.chumby.com/index.php?title=Devices) |
| TSC2100 proc register namespace | The `/proc/chumby/tsc2100/` namespace includes `audiodac-page2`, `audioadc-page2`, `sidetone-page2`, and TSC2100 register entries. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Audio proc namespace | `/proc/chumby/audio` exists under the Chumby-specific `/proc/chumby` driver namespace. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Side-tone controls | `/proc/chumby/audio/side-tone/` includes `digital-gain`, `digital-mute`, `analog-gain`, and `analog-mute`. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Mixer namespace | `/proc/chumby/audio/mixer` exists under the Chumby audio proc namespace. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Speaker mixer paths | Mixer paths are documented for `both-speakers`, `right-speaker`, and `left-speaker`. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Speaker volume paths | Mixer volume paths are documented at `/proc/chumby/audio/mixer/both-speakers/volume`, `/right-speaker/volume`, and `/left-speaker/volume`. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Speaker mute paths | Mixer mute paths are documented at `/proc/chumby/audio/mixer/both-speakers/mute`, `/right-speaker/mute`, and `/left-speaker/mute`. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Touch click audio feedback | Touch click feedback can be enabled with `echo 1 > /proc/chumby/touchscreen/touchclick` and disabled with `echo 0 > /proc/chumby/touchscreen/touchclick`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Make_your_chumby_click_when_you_touch_the_screen) |
| Headphone manager utility | The Chumby software tools page lists `headphone_manager` as the daemon responsible for disabling internal speakers when headphones or external speakers are connected. | [Chumby Wiki: Chumby Software Applications, Scripts and Tools](https://wiki.chumby.com/index.php?title=Chumby_Software_Applications%2C_Scripts_and_Tools) |
| Headphone utility command | The Chumby software tools page lists `headphone_mgr` among installed utilities. | [Chumby Wiki: Chumby Software Applications, Scripts and Tools](https://wiki.chumby.com/index.php?title=Chumby_Software_Applications%2C_Scripts_and_Tools) |
| Control Panel volume events | Control Panel external events include `MusicPlayer` values for `setVolume`, `setMute`, and `setBalance`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Sending_events_to_the_Control_Panel) |
| Flash media support | Ironforge widget documentation lists support for external MP3 files. | [Chumby Wiki: Developing widgets for chumby](https://wiki.chumby.com/index.php?title=Developing_widgets_for_chumby) |
| Flash video audio context | Ironforge widget documentation lists support for FLV video encoded with ON2 and Sorenson Spark codecs. | [Chumby Wiki: Developing widgets for chumby](https://wiki.chumby.com/index.php?title=Developing_widgets_for_chumby) |

## Unknowns

- Exact OSS or ALSA device nodes on stock HW 3.7 firmware.
- Exact accepted numeric ranges for `/proc/chumby/audio/mixer/*/volume`.
- Exact accepted values for `/proc/chumby/audio/mixer/*/mute`.
- Exact audio sample rates supported by the TSC2100 path in the stock kernel.
- Exact command-line audio players present on stock Classic firmware.
- Whether stock firmware exposes ALSA mixer names.
- Whether microphone capture is usable from user space without Flash.
- Whether simultaneous playback and touchscreen click feedback share a mixer path.
