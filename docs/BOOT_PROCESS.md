# Boot Process Reverse Engineering Notes

Scope: Chumby Classic / Ironforge boot and recovery behavior; the Chumby Wiki
identifies Chumby Classic as Ironforge. [[source](https://wiki.chumby.com/index.php?title=Devices)]
Each finding is linked to a source. Unverified details are listed under
[Unknowns](#unknowns).

## Sourced Findings

| Area | Finding | Source |
| --- | --- | --- |
| Production target | The Chumby Wiki identifies Chumby Classic as the Ironforge production Chumby device. | [Chumby Wiki: Devices](https://wiki.chumby.com/index.php?title=Devices) |
| Normal boot splash sequence | During a normal boot, before the opening animation, the Chumby displays four images. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Your_own_splash_screens) |
| Bootloader splash images | The first two normal boot splash images are displayed by the bootloader. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Your_own_splash_screens) |
| Kernel splash image | The third normal boot splash image is displayed by the kernel. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Kernel_Screen) |
| Init splash image | The final normal boot splash image is displayed by `/etc/init.d/rcS`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Init_Script_Screen) |
| Bootloader image storage | The bootloader's two normal splash screens are stored as named sections in the configuration block. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Bootloader_Screens) |
| Bootloader image block names | The documented bootloader splash replacement flow reads and writes blocks named `img1` and `img2` with `config_util`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Bootloader_Screens) |
| Normal root filesystem name | Ironforge-specific notes refer to normal mode as `rfs1`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Running_something_at_boot_without_debugchumby_.28IronForge_Chumby_Classic_ONLY.29) |
| Special Options filesystem name | Ironforge-specific notes refer to Special Options mode as `rfs2`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Running_something_at_boot_without_debugchumby_.28IronForge_Chumby_Classic_ONLY.29) |
| Special Options entry | Special Options mode is entered by powering on while pressing the touchscreen. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Running_something_at_boot_without_debugchumby_.28IronForge_Chumby_Classic_ONLY.29) |
| USB startup script | A USB file named `debugchumby` can contain shell commands that run on startup. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Run_processes_on_start-up) |
| Startup hooks | Files named `userhook0`, `userhook1`, and `userhook2` can be placed on USB root or in `/psp/rfs1/` internal storage. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Run_processes_on_start-up) |
| Ironforge boot customization path | Ironforge normal boot can be customized through `/psp/rfs1/rcS`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Running_something_at_boot_without_debugchumby_.28IronForge_Chumby_Classic_ONLY.29) |
| Ironforge boot customization risk | The Chumby Wiki warns that editing `/psp/rfs1/rcS` can break the boot procedure. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Running_something_at_boot_without_debugchumby_.28IronForge_Chumby_Classic_ONLY.29) |
| Broken boot script recovery | A broken `/psp/rfs1/rcS` can be removed by booting Special Options mode and running a USB `debugchumby` script that deletes `/psp/rfs1/rcS`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Running_something_at_boot_without_debugchumby_.28IronForge_Chumby_Classic_ONLY.29) |
| Firmware update from USB | The Classic firmware update flow uses a USB flash drive, Special Options mode, `Install updates`, and `Install from USB flash drive`. | [Chumby Wiki: Troubleshooting](https://wiki.chumby.com/index.php?title=Troubleshooting) |
| Classic update file handling | For Chumby Classic, the update ZIP is unpacked and its contents are moved to the top level of the USB flash drive. | [Chumby Wiki: Troubleshooting](https://wiki.chumby.com/index.php?title=Troubleshooting) |
| Kernel update from USB | Classic kernel installation uses a USB `update2` directory containing `k1.bin.zip`, then Special Options mode and Install from USB flash drive. | [Chumby Wiki: Hacking Linux for chumby](https://wiki.chumby.com/index.php?title=Hacking_Linux_for_chumby#Installing_the_kernel_image) |
| Bootloader model in update patent | A Chumby software-update patent names `BL` as the initial bootloader and `2BL` as the second bootloader. | [Justia Patents: US8261256](https://patents.justia.com/patent/8261256) |
| Boot state semaphore | A Chumby software-update patent describes an `MSP` semaphore used by the bootloader to choose auto-update mode or normal operation. | [Google Patents: US8839224B2](https://patents.google.com/patent/US8839224B2/en) |
| Normal update-model boot path | A Chumby software-update patent describes `Kernel 1` / `K1` mounting `RFS1` during normal operation. | [Google Patents: US8839224B2](https://patents.google.com/patent/US8839224B2/en) |
| Auto-update boot path | A Chumby software-update patent describes `Kernel 2` / `K2` mounting `RFS2` during auto-update mode. | [Google Patents: US8839224B2](https://patents.google.com/patent/US8839224B2/en) |

## Unknowns

- Exact bootloader implementation name and version.
- Whether the Classic bootloader exposes an interactive serial command shell.
- Exact boot order before Linux control passes to `/etc/init.d/rcS`.
- Exact conditions under which `debugchumby` is executed in normal mode versus Special Options mode.
- Exact partition offsets for `BL`, `2BL`, `K1`, `K2`, `RFS1`, `RFS2`, `PSP`, `TST`, and `MSP` on HW 3.7.
- Whether HW 3.7 can boot a full Linux root filesystem from USB rather than only running USB scripts or applying USB updates.
- Whether HW 3.7 has any SD boot path.
