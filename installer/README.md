# Installer

Sprint 3 provides a USB preparation workflow for the bootable Chumby MVP.

The installer does not download Zurk Offline Firmware and does not intentionally modify Chumby internal flash. It prepares a USB stick with the user-supplied Zurk Classic archive plus a HA-Chumby startup overlay.

## Files

- `prepare_usb.ps1`: Windows host-side USB preparation script.
- `overlay/debugchumby`: USB-root startup entrypoint for the Chumby.
- `overlay/ha-chumby/start.sh`: Minimal shell application that writes the boot screen.
- `overlay/ha-chumby/boot-screen.rgb565`: 320 x 240 RGB565 boot confirmation screen.

## Expected firmware package

Use `zurk_chumby_classic.zip`, the last Zurk Offline Firmware package identified for Chumby Classic.

See `docs/installation/PREPARE_USB.md` for the complete process and safety notes.
