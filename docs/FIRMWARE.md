# Firmware Reverse Engineering Notes

Scope: Chumby Classic / Ironforge firmware, source availability, update files,
toolchains, and platform services; the Chumby Wiki identifies Chumby Classic as
Ironforge. [[source](https://wiki.chumby.com/index.php?title=Devices)] Each
finding is linked to a source. Unverified details are listed under
[Unknowns](#unknowns).

## Sourced Findings

| Area | Finding | Source |
| --- | --- | --- |
| Product codename | The Chumby device table identifies Chumby Classic as Ironforge. | [Chumby Wiki: Devices](https://wiki.chumby.com/index.php?title=Devices) |
| GPL/LGPL source availability | Chumby states that GPL and LGPL source code contained in the product is available from `http://files.chumby.com/source`. | [Chumby source page](https://www.chumby.com/source) |
| Classic recovery firmware package | Chumby troubleshooting lists the Classic firmware package as `http://files.chumby.com/resources/classic/1-7-3/update.zip`. | [Chumby Wiki: Troubleshooting](https://wiki.chumby.com/index.php?title=Troubleshooting) |
| Classic update packaging | Chumby Classic update ZIP contents are unpacked and copied to the top level of a USB flash drive for update. | [Chumby Wiki: Troubleshooting](https://wiki.chumby.com/index.php?title=Troubleshooting) |
| Classic 1.7 kernel source | Chumby documents the Classic 1.7 kernel source archive as `linux-2.6.16-chumby-1.7.0.tar.gz` under `source/ironforge/build1.7.1649/`. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Building_the_chumby_1.7_kernel) |
| Classic 1.6 kernel source | Chumby documents the Classic 1.6 kernel source archive as `linux-2.6.16-chumby-1.6.0.tar.gz` under `source/ironforge/build733/`. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Building_the_chumby_1.6_kernel) |
| Classic 1.5 kernel source | Chumby documents the Classic 1.5 kernel source archive as `linux-2.6.16-chumby-1.5.0.tar.gz` under `source/ironforge/build565/`. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Building_the_chumby_1.5_kernel) |
| Classic kernel version | Chumby 1.7, 1.6, and 1.5 Classic kernel build instructions all name Linux `2.6.16` source archives. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Building_and_Installing_a_new_Classic_chumby_kernel) |
| Deprecated Ironforge kernel note | The deprecated Ironforge section says the production Chumby runs a Linux `2.6.16` kernel. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Ironforge) |
| Classic 1.7 toolchain | Chumby 1.7 Classic kernel instructions say to install the GNU Toolchain using GCC 4.3.2. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Building_the_chumby_1.7_kernel) |
| Ironforge firmware 1.7 ABI note | The GNU Toolchain page says Ironforge firmware 1.7 switched to GCC 4.3.2 and GLIBC 2.8. | [Chumby Wiki: GNU Toolchain](https://wiki.chumby.com/index.php?title=GNU_Toolchain) |
| Classic kernel build command | Chumby 1.7 Classic kernel instructions use `ARCH=arm BOARD=mx21ads CROSS_COMPILE=arm-linux- make`. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Building_the_chumby_1.7_kernel) |
| Classic kernel output packaging | Chumby 1.7 Classic kernel instructions align `arch/arm/boot/zImage` with `align.pl` and package it as `k1.bin.zip`. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Building_the_chumby_1.7_kernel) |
| Classic WiFi driver source | Chumby documents `rt73-chumby-1.7.0.tar.gz` as the Ralink WiFi driver source for the 1.7 kernel. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Building_the_Wi-Fi_driver) |
| Built-in SSH daemon | The hidden Control Panel can launch the built-in Secure Shell Daemon. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Hidden_screen_in_Control_Panel) |
| SSH login behavior | The Chumby Wiki documents SSH login as user `root` with no password after starting `sshd`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Open_a_secure_shell_.28SSH.29_console_on_the_chumby) |
| SSH persistence flag | Creating `/psp/start_sshd` starts `sshd` whenever the device connects to a network. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Launching_sshd_at_startup) |
| Built-in web server | Chumby starts a small HTTP server on port 80 that exposes wireless and memory statistics pages. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Built_in_web_server) |
| BusyBox HTTP server | The Chumby Classic and Chumby One run a simple HTTP server using BusyBox. | [Chumby Wiki: Using the busybox HTTP server](https://wiki.chumby.com/index.php?title=Using_the_busybox_HTTP_server) |
| CGI extension path | BusyBox HTTP server scripts can be added under `/psp/cgi-bin`. | [Chumby Wiki: Using the busybox HTTP server](https://wiki.chumby.com/index.php?title=Using_the_busybox_HTTP_server) |
| Built-in editor | Production Chumby devices include a lightweight version of `vi`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks) |
| Native GCC installer prompt | The Phidget guide says typing `gcc` on the device prompts to download and install a GCC package from Chumby-hosted files. | [Chumby Wiki: Getting Phidget on chumby](https://wiki.chumby.com/index.php?title=Getting_Phidget_on_chumby) |
| Flash Lite runtime | Ironforge widget documentation says widgets target Adobe Flash Lite 3.1 and the Flash Lite Player version was 3.1.5 as of November 2009. | [Chumby Wiki: Developing widgets for chumby](https://wiki.chumby.com/index.php?title=Developing_widgets_for_chumby) |

## Unknowns

- Exact firmware version installed on the target HW 3.7 unit.
- Exact contents and checksums of the Classic `1-7-3/update.zip` package.
- Exact package manager command on stock Classic firmware.
- Exact Python availability on stock Classic firmware.
- Exact init system beyond the documented `/etc/init.d/rcS` entry point.
- Exact service supervision behavior for the Control Panel and Flash player.
- Exact proprietary components present in the stock firmware image.
- Exact license status of non-GPL firmware components.
- Exact bootloader source availability for Classic / Ironforge.
- Exact build reproducibility of the published Classic source archives.
