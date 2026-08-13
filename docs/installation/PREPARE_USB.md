# Prepare USB: Bootable HA-Chumby MVP

Status: Sprint 3 MVP preparation guide.

Goal: boot a Chumby Classic / beanbag HW 3.7 from a USB stick and automatically display the HA-Chumby boot confirmation screen without intentionally modifying internal flash.

Target screen:

```text
HA-Chumby

Boot successful

Version 0.1
```

## Safety Position

This MVP uses the USB `debugchumby` startup mechanism and does not intentionally run a firmware installer. The HA-Chumby overlay replaces the USB-root `debugchumby` entrypoint with a minimal startup script that draws the boot confirmation screen.

This safety position exists because Zurk documentation conflicts:

- The early Zurk forum instructions describe USB-resident behavior where removing the USB stick and power cycling resets the Chumby. [Zurk forum thread](https://forum.chumby.com/viewtopic.php?id=7831)
- The later SourceForge README describes a loader workflow that reboots and tells the user to remove the USB stick, which is consistent with an onboard installation flow. [SourceForge README](https://sourceforge.net/projects/zurk/files/)

For the Sprint 3 constraint `Do not modify the internal firmware`, the safest approach is to prepare a Zurk Classic USB stick but prevent the Zurk USB-root `debugchumby` from running by preserving it as `debugchumby.zurk-original` and installing HA-Chumby's no-flash `debugchumby` overlay.

## Exact Firmware Package

Use this package name:

```text
zurk_chumby_classic.zip
```

SourceForge identifies `zurk_chumby_classic.zip` as the last Zurk firmware for Chumby Classic and says the Chumby Classic is no longer supported by current Zurk releases. [SourceForge README](https://sourceforge.net/projects/zurk/files/)

Do not use `zurk_chumby_one.zip` for this Sprint 3 Chumby Classic MVP. SourceForge separately lists that package for Chumby One / Infocast 3.5. [SourceForge README](https://sourceforge.net/projects/zurk/files/)

This project does not download or redistribute Zurk firmware.

## Required USB Format

| Requirement | Value | Source |
| --- | --- | --- |
| Filesystem | FAT32 | [SourceForge README](https://sourceforge.net/projects/zurk/files/) |
| Size | 512 MB or greater | [SourceForge README](https://sourceforge.net/projects/zurk/files/) |
| Initial contents | Blank USB stick before extraction | [SourceForge README](https://sourceforge.net/projects/zurk/files/) |
| Extraction location | USB root folder | [SourceForge README](https://sourceforge.net/projects/zurk/files/) |
| Directory handling | Preserve the ZIP directory structure | [SourceForge README](https://sourceforge.net/projects/zurk/files/) |

## USB Directory Structure

After running `installer/prepare_usb.ps1`, the USB root must include at least:

```text
/debugchumby
/debugchumby.zurk-original        optional, present when the Zurk archive had debugchumby
/HA-CHUMBY-MANIFEST.txt
/ha-chumby/start.sh
/ha-chumby/boot-screen.rgb565
```

The USB stick should also contain the other files and directories extracted from `zurk_chumby_classic.zip`, because SourceForge says the archive must be extracted to the USB root with directory structure preserved. [SourceForge README](https://sourceforge.net/projects/zurk/files/)

## What Each HA-Chumby File Does

| File | Purpose |
| --- | --- |
| `/debugchumby` | USB-root startup entrypoint discovered by the Chumby startup process; it `exec`s HA-Chumby in the foreground so stock boot does not immediately resume. |
| `/debugchumby.zurk-original` | Backup of Zurk's original USB-root `debugchumby`, if one was present in the archive. |
| `/ha-chumby/start.sh` | Minimal long-running shell application that logs startup, optionally stops the stock Control Panel, writes the boot screen to `/dev/fb0` or `/dev/fb`, and keeps redrawing it. |
| `/ha-chumby/boot-screen.rgb565` | Pre-rendered 320 x 240 RGB565 image containing the Sprint 3 boot confirmation text. |
| `/HA-CHUMBY-MANIFEST.txt` | Host-generated preparation manifest. |

Chumby Wiki documents USB-root `debugchumby` as the easiest and safest startup customization path. [Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Run_processes_on_start-up)

Chumby Wiki documents `/dev/fb` as the framebuffer-style video memory interface. [Chumby /dev notes](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fdev)

## Host Preparation Checklist

Run these steps on the development computer.

| Done | Step |
| --- | --- |
| [ ] | Manually obtain `zurk_chumby_classic.zip` from SourceForge. |
| [ ] | Insert a USB stick of at least 512 MB. |
| [ ] | Format the USB stick as FAT32. |
| [ ] | Confirm the USB stick is blank. |
| [ ] | Open PowerShell from the repository root. |
| [ ] | Run `installer\prepare_usb.ps1 -UsbRoot X:\ -ZurkZip C:\path\to\zurk_chumby_classic.zip`, replacing paths as needed. |
| [ ] | If the USB root is intentionally not empty, rerun with `-Force`. |
| [ ] | Confirm `/debugchumby` exists on the USB root. |
| [ ] | Confirm `/ha-chumby/start.sh` exists. |
| [ ] | Confirm `/ha-chumby/boot-screen.rgb565` exists. |
| [ ] | Confirm `/HA-CHUMBY-MANIFEST.txt` exists. |
| [ ] | Eject the USB stick cleanly. |

Example:

```powershell
.\installer\prepare_usb.ps1 -UsbRoot E:\ -ZurkZip C:\Users\Surface\Downloads\zurk_chumby_classic.zip
```


## If HA-Chumby Files Are Missing

If the USB stick does not contain `/HA-CHUMBY-MANIFEST.txt`, `/ha-chumby/start.sh`, and `/ha-chumby/boot-screen.rgb565` after running the preparation script, the HA-Chumby overlay was not copied correctly.

Use the current `installer/prepare_usb.ps1` and rerun the preparation command. The script now verifies these required files and stops with an error if any of them are missing.

Expected files after a successful run:

```text
/HA-CHUMBY-MANIFEST.txt
/debugchumby
/ha-chumby/start.sh
/ha-chumby/boot-screen.rgb565
```

## Sprint 4 Persistence Behavior

Sprint 4 changed the USB startup model. `debugchumby` no longer starts HA-Chumby in the background and exits. It now uses `exec sh /mnt/usb/ha-chumby/start.sh` so HA-Chumby becomes the foreground process for the USB startup path.

`start.sh` writes detailed progress to `/tmp/ha-chumby.log`, calls `stop_control_panel` if that stock command is available, writes the boot screen, and redraws the framebuffer every two seconds.

See `docs/installation/BOOT_PERSISTENCE.md` for the design note and source analysis.
## Boot Checklist

Run these steps on real Chumby Classic HW 3.7 hardware.

| Done | Step |
| --- | --- |
| [ ] | Confirm the Chumby is powered off. |
| [ ] | Insert the prepared USB stick. |
| [ ] | Power on the Chumby. |
| [ ] | Wait for the normal USB startup path to run. |
| [ ] | Confirm the display shows `HA-Chumby`, `Boot successful`, and `Version 0.1`. |
| [ ] | Leave the USB stick inserted. |
| [ ] | Power off the Chumby. |
| [ ] | Power on the Chumby again with the same USB stick inserted. |
| [ ] | Confirm the same HA-Chumby boot screen appears again. |
| [ ] | Repeat at least three power cycles. |

## Recovery Checklist

| Situation | Action | Source |
| --- | --- | --- |
| The Chumby ignores the USB stick. | Re-check FAT32 format, USB root placement, and presence of `/debugchumby`. | [SourceForge README](https://sourceforge.net/projects/zurk/files/), [Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Run_processes_on_start-up) |
| The Chumby boots but no HA-Chumby screen appears. | Check `/tmp/ha-chumby.log` over SSH if SSH is available. | [Chumby tricks SSH](https://wiki.chumby.com/index.php?title=Chumby_tricks#Open_a_secure_shell_.28SSH.29_console_on_the_chumby) |
| The screen remains on stock UI. | Verify the USB-root `debugchumby` is the HA-Chumby overlay file, not Zurk's original. | [Chumby tricks startup](https://wiki.chumby.com/index.php?title=Chumby_tricks#Run_processes_on_start-up) |
| The display is corrupted. | The framebuffer may use a different node or pixel layout; record the behavior in hardware validation notes. | [Chumby /dev notes](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fdev) |
| Official firmware repair is required. | Use Chumby Classic official `1-7-3/update.zip` restore flow from Special Options mode. | [Chumby troubleshooting](https://wiki.chumby.com/index.php?title=Troubleshooting#Firmware_restore) |

## Internal Flash Safety Checklist

| Done | Check |
| --- | --- |
| [ ] | Do not choose SourceForge's install-and-remove-USB flow for this Sprint 3 MVP. |
| [ ] | Do not run `/debugchumby.zurk-original` until hardware testing proves it does not write internal flash. |
| [ ] | Keep the USB stick inserted during boot validation. |
| [ ] | Verify the device still boots its previous behavior when the USB stick is removed. |
| [ ] | Record whether any persistent settings changed after USB removal. |

## Known Limitations

- The exact contents of `zurk_chumby_classic.zip` are not committed to this repository.
- This project does not verify the full Zurk archive manifest because firmware is not downloaded or redistributed here.
- The framebuffer asset assumes 320 x 240 RGB565 output, which matches the documented 320 x 240 x 16 display, but must be validated on real hardware. [Chumby Wiki Devices](https://wiki.chumby.com/index.php?title=Devices)
- The startup script tries `/dev/fb0` and `/dev/fb`; exact framebuffer nodes must be verified on the target unit. [Chumby /dev notes](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fdev)
- No Home Assistant integration is included.
- No alarms are included.
- No networking is added beyond whatever the existing firmware already performs.
