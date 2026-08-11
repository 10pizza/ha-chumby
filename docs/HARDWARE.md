# Chumby Classic Hardware and Platform Specification

Scope: Chumby Classic / Ironforge, with emphasis on hardware revision 3.7. The
Chumby Wiki identifies the Chumby Classic codename as Ironforge and lists it as a
production Chumby device. [[devices](https://wiki.chumby.com/index.php?title=Devices)]

Rule for this document: each technical finding below includes a source link. If
a requested item could not be confirmed from the collected sources, it is listed
under [Unknowns](#unknowns).

## Summary Table

| Area | Sourced finding | Source |
| --- | --- | --- |
| Product codename | Chumby Classic is identified as `Ironforge`. | [Chumby Wiki: Devices](https://wiki.chumby.com/index.php?title=Devices) |
| CPU | 350 MHz Freescale i.MX21 `MC94MX21DVKN3` ARM9 controller. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| CPU architecture | The Chumby Classic device table lists `Freescale iMX21 ARM926EJ-S 350MHz`. | [Chumby Wiki: Devices](https://wiki.chumby.com/index.php?title=Devices) |
| RAM | 64 MB SDRAM on a 32-bit data path. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| Flash | Hynix `HY27US` 64 MB NAND Flash ROM. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| Removable SD | The collected Chumby Classic hardware sources list NAND flash, not an SD or microSD storage device. | [Chumby Wiki: Devices](https://wiki.chumby.com/index.php?title=Devices), [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| Display | DataImage 320 x 240, 16 bpp TFT display with touchscreen. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| Display resolution | 320 x 240 x 16 TFT with touchscreen. | [Chumby Wiki: Devices](https://wiki.chumby.com/index.php?title=Devices) |
| Framebuffer | Firmware 1.6.0 and later can expose two framebuffers over HTTP CGI: `fb0` for the widget framebuffer and `fb1` for the Control Panel overlay framebuffer. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Using_a_browser_to_see_what.27s_on_your_chumby) |
| Framebuffer access | The hidden Control Panel screen has an `FB CGI` option that enables frame buffer access through `/dev/fb` content via CGI. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Hidden_screen_in_Control_Panel) |
| Touchscreen controller | Texas Instruments TSC2100 programmable touchscreen controller with stereo DAC. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| Touchscreen runtime interface | The Chumby Wiki documents `/dev/ts` as a direct touchscreen driver interface and documents `/proc/chumby/touchscreen/coordinates` for coordinate values. | [Chumby Wiki: Chumby device settings information on /dev](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fdev) |
| Touchscreen click feedback | Touch click feedback is controlled through `/proc/chumby/touchscreen/touchclick` with `1` enabling it and `0` disabling it. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Make_your_chumby_click_when_you_touch_the_screen) |
| Audio codec / DAC | The TSC2100 is listed as both touchscreen controller and stereo DAC. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| Speakers | 2 W stereo speakers with headphone jack. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| Microphone | Built-in microphone. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| Mixer controls | Control Panel external events include `MusicPlayer` values for `setVolume`, `setMute`, and `setBalance`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Sending_events_to_the_Control_Panel) |
| WiFi adapter | Xterasys 3135G 802.11g USB WiFi adapter using a Ralink chipset. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| WiFi chipset detail | DeviWiki lists the Chumby Classic WiFi module as Xterasys XN-3135G over USB with Ralink `RT2571W` and `RT2528` chips, supporting 802.11b/g. | [DeviWiki: Chumby Classic](https://deviwiki.com/wiki/Chumby_Classic) |
| WiFi driver source | Chumby 1.7 kernel build notes describe building the Ralink `rt73` driver against the `linux-2.6.16-chumby-1.7.0` kernel tree. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Building_the_Wi-Fi_driver) |
| USB support | Three USB 2.0 full-speed ports: one internal and two external. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| External USB ports | The device table lists two USB 2.0 full-speed ports for Chumby Classic. | [Chumby Wiki: Devices](https://wiki.chumby.com/index.php?title=Devices) |
| Wired Ethernet support | Firmware 1.7 and later include Ethernet support, with documented USB Ethernet examples for Linksys USB200M and Trendnet TU-ET100C adapters. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Use_wired_Ethernet) |
| Classic firmware package | Chumby troubleshooting lists the Classic recovery firmware package under version `1-7-3`. | [Chumby Wiki: Troubleshooting](https://wiki.chumby.com/index.php?title=Troubleshooting) |
| Linux kernel | Chumby firmware version 1.7 uses Linux `2.6.16` from `linux-2.6.16-chumby-1.7.0.tar.gz`. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Building_the_chumby_1.7_kernel) |
| Older production kernel | The deprecated Ironforge notes state that the production Chumby runs a Linux `2.6.16` kernel. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Ironforge) |
| Firmware 1.7 toolchain ABI | As of Ironforge firmware version 1.7, Chumby switched to GCC 4.3.2 and GLIBC 2.8 for the GNU toolchain. | [Chumby Wiki: GNU Toolchain](https://wiki.chumby.com/index.php?title=GNU_Toolchain) |
| Open source firmware/source | Chumby states that GPL/LGPL source code for software in the product is available for download from `files.chumby.com/source`. | [Chumby source page](https://www.chumby.com/source) |
| Classic kernel source | The Chumby 1.7 Classic kernel source archive is documented as `linux-2.6.16-chumby-1.7.0.tar.gz` under the Ironforge source tree. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Building_the_chumby_1.7_kernel) |
| SSH daemon access | The hidden Control Panel screen includes `SSHD`, which launches the built-in Secure Shell Daemon. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Hidden_screen_in_Control_Panel) |
| SSH login | The Chumby Wiki documents logging in over SSH as user `root` with no password after starting `sshd`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Open_a_secure_shell_.28SSH.29_console_on_the_chumby) |
| SSH autostart | Creating `/psp/start_sshd` starts `sshd` whenever the Chumby successfully connects to a network; an empty `start_sshd` file on USB can start SSH without making it permanent. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Launching_sshd_at_startup) |
| Built-in editor | Chumby production devices include a lightweight `vi`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks) |
| Built-in HTTP server | On startup, Chumby launches a small HTTP server on port 80 that can show wireless statistics and memory statistics. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Built_in_web_server) |

## Flash and Boot Layout

| Item | Sourced finding | Source |
| --- | --- | --- |
| NAND capacity | Chumby Classic hardware uses 64 MB NAND flash ROM. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| Normal root filesystem name | Ironforge-specific boot customization notes refer to normal mode as `rfs1`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Running_something_at_boot_without_debugchumby_.28IronForge_Chumby_Classic_ONLY.29) |
| Special options filesystem name | Ironforge-specific recovery notes refer to Special Options mode as `rfs2`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Running_something_at_boot_without_debugchumby_.28IronForge_Chumby_Classic_ONLY.29) |
| Persistent storage path | Chumby customization and SSH configuration notes store persistent files under `/psp`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Launching_sshd_at_startup) |
| Update partition model | A Chumby software-update patent describes partitions named `RFS1`, `K2`, `RFS2`, `BL`, `2BL`, `PSP`, `TST`, and `MSP`. | [Justia Patents: US8261256](https://patents.justia.com/patent/8261256) |
| Bootloader names | The same patent defines `BL` as the initial bootloader and `2BL` as the second bootloader. | [Justia Patents: US8261256](https://patents.justia.com/patent/8261256) |
| Normal boot path | The Chumby update patent describes `Kernel 1` / `K1` loading the primary root filesystem image `RFS1` for normal mode operation. | [Google Patents: US8839224B2](https://patents.google.com/patent/US8839224B2/en) |
| Update boot path | The Chumby update patent describes `Kernel 2` / `K2` loading `RFS2` for auto-update mode. | [Google Patents: US8839224B2](https://patents.google.com/patent/US8839224B2/en) |
| Update-mode root filesystem format | The Chumby update patent describes `RFS2` as read-only `cramfs`. | [Google Patents: US8839224B2](https://patents.google.com/patent/US8839224B2/en) |
| Normal root filesystem format | The Chumby update patent describes `RFS1` as `JFFS2`. | [Justia Patents: US20130061216](https://patents.justia.com/patent/20130061216) |
| Persistent storage format | The Chumby update patent describes `PSP` as `JFFS2`. | [Justia Patents: US8261256](https://patents.justia.com/patent/8261256) |
| Boot state control | The Chumby update patent describes an `MSP` semaphore used by the bootloader to select auto-update or normal operation. | [Google Patents: US8839224B2](https://patents.google.com/patent/US8839224B2/en) |

## USB, SD, Recovery, and SSH

| Item | Sourced finding | Source |
| --- | --- | --- |
| USB update | Classic firmware recovery/update is performed by putting the Classic update files at the top level of a USB flash drive, booting while touching the screen to enter Special Options mode, then selecting Install updates and Install from USB flash drive. | [Chumby Wiki: Troubleshooting](https://wiki.chumby.com/index.php?title=Troubleshooting) |
| Kernel update from USB | Classic kernel install instructions use an `update2` directory on a USB storage drive containing `k1.bin.zip`, then Special Options mode and Install from USB flash drive. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Installing_the_kernel_image) |
| Startup script from USB | Creating a `debugchumby` shell script on a USB drive is documented as the easiest and safest way to run commands at startup. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Run_processes_on_start-up) |
| Startup hooks | `userhook0`, `userhook1`, and `userhook2` can be placed on USB root or internal storage under `/psp/rfs1/`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Run_processes_on_start-up) |
| Recovery from broken Ironforge boot script | If `/psp/rfs1/rcS` breaks normal boot, recovery is documented by booting Special Options mode and running a USB `debugchumby` script that removes `/psp/rfs1/rcS`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Running_something_at_boot_without_debugchumby_.28IronForge_Chumby_Classic_ONLY.29) |
| Factory reset assistance | A FAT32 USB `debugchumby` script can copy network and timezone configuration into `/psp`, set `/psp/start_sshd`, and start `/sbin/sshd`; the same page documents using Special Options mode for factory reset. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Setting_up_a_fresh_Chumby.2C_or_after_factory_reset) |
| Touchscreen calibration recovery | A USB file named `ts_settings` containing calibration values can restore touchscreen calibration well enough to navigate Control Panel calibration. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Screwed_up_your_touchscreen_calibration.3F) |
| SSH one-shot enablement | The hidden Control Panel can launch `sshd`; root login with no password is documented after `sshd` is started. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Open_a_secure_shell_.28SSH.29_console_on_the_chumby) |
| SSH persistent enablement | `touch /psp/start_sshd` enables SSH startup after successful network connection. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Launching_sshd_at_startup) |
| SSH USB enablement | An empty file named `start_sshd` on a USB flash drive starts SSH without making SSH startup permanent. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Launching_sshd_at_startup) |
| Password hardening on Ironforge | Ironforge password-protected SSH can be set up by copying `/etc` into `/psp/etc`, editing the shadow entry, and bind-mounting `/psp/etc` over `/etc`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#...on_Ironforge) |

## Package Manager and Development Tooling

| Item | Sourced finding | Source |
| --- | --- | --- |
| Cross toolchain | Ironforge firmware 1.7 uses a GCC 4.3.2 / GLIBC 2.8 GNU toolchain according to Chumby toolchain notes. | [Chumby Wiki: GNU Toolchain](https://wiki.chumby.com/index.php?title=GNU_Toolchain) |
| Kernel build toolchain | Chumby 1.7 Classic kernel build instructions use `ARCH=arm BOARD=mx21ads CROSS_COMPILE=arm-linux- make`. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Building_the_chumby_1.7_kernel) |
| Native GCC helper behavior | The Phidget guide says typing `gcc` on the device prompts to download and install a GCC package from Chumby-hosted files. | [Chumby Wiki: Getting Phidget on chumby](https://wiki.chumby.com/index.php?title=Getting_Phidget_on_chumby) |
| Built-in CGI/script environment | The BusyBox HTTP server page documents CGI scripts under `/psp/cgi-bin`, and says scripts can be C binaries or interpreted by a language installed on the device. | [Chumby Wiki: Using the busybox HTTP server](https://wiki.chumby.com/index.php?title=Using_the_busybox_HTTP_server) |

## Existing Open Source Firmware and Source

| Item | Sourced finding | Source |
| --- | --- | --- |
| GPL/LGPL source availability | Chumby states that GPL and LGPL source code contained in the product is available from `http://files.chumby.com/source`. | [Chumby source page](https://www.chumby.com/source) |
| Classic 1.7 kernel source | Chumby documents the Classic 1.7 kernel source archive as `http://files.chumby.com/source/ironforge/build1.7.1649/linux-2.6.16-chumby-1.7.0.tar.gz`. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Building_the_chumby_1.7_kernel) |
| Classic 1.7 WiFi driver source | Chumby documents the Classic 1.7 Ralink driver archive as `http://files.chumby.com/source/ironforge/build1.7.1649/rt73-chumby-1.7.0.tar.gz`. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Building_the_Wi-Fi_driver) |
| Classic firmware recovery package | Chumby troubleshooting lists the Classic firmware package as `http://files.chumby.com/resources/classic/1-7-3/update.zip`. | [Chumby Wiki: Troubleshooting](https://wiki.chumby.com/index.php?title=Troubleshooting) |

## Unknowns

The following requested details were not confirmed by the collected sources and
must be verified on real hardware, from schematics, or from firmware images
before implementation depends on them.

- Exact HW 3.7 board-level flash partition offsets and sizes.
- Exact bootloader binary name, version, source availability, and command shell.
- Whether HW 3.7 supports full Linux root filesystem boot from USB, as distinct
  from USB update and USB startup scripts.
- Whether HW 3.7 supports boot from SD; the collected Classic hardware sources
  list NAND flash but do not document an SD slot or SD boot path.
- Exact framebuffer device nodes beyond the documented `fb0` and `fb1` CGI
  naming.
- Exact Linux input event device names for the touchscreen on stock firmware.
- Exact ALSA/OSS device names and mixer device paths.
- Exact package manager command, if any, on stock Classic firmware.
- Exact Python version availability on stock Classic firmware.
- Exact firmware version currently present on target hardware.

## Source Notes

- Chumby Wiki pages are the primary sources for this document where available.
- DeviWiki is used only for WiFi chip detail that was not fully enumerated by
  the Chumby Wiki hardware page.
- Patent sources are used only for the named Chumby update/partition model, not
  as a substitute for board-level partition offsets.
