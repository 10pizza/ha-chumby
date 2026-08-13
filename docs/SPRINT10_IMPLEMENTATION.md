# Sprint 10 Implementation

Status: Sprint 10 runtime restoration implementation.

## Implementation Summary

`installer/overlay/ha-chumby/start.sh` now restores the original Zurk web runtime after drawing the HA-Chumby splash screen.

The implementation follows the preferred strategy from Sprint 10:

1. Option A: execute `/mnt/usb/debugchumby.zurk-original` after the HA-Chumby framebuffer confirmation.
2. Option B fallback: execute `/mnt/usb/lighty/startup.sh` only if the original Zurk startup file is missing.
3. Option C, direct lighttpd launch from HA-Chumby, is not implemented.

## Runtime Changes

| Area | Change |
| --- | --- |
| Splash ordering | HA-Chumby splash is drawn before restoring Zurk startup. |
| Zurk startup | `start.sh` runs `sh /mnt/usb/debugchumby.zurk-original` when available. |
| Fallback startup | `start.sh` runs `sh /mnt/usb/lighty/startup.sh` only when the preserved original hook is missing. |
| Diagnostics | Logs process list, listening ports, startup exit code, and PASS/FAIL runtime checks. |
| Foreground control | HA-Chumby remains in a foreground redraw loop so `debugchumby` does not return to stock boot flow. |

## Why This Is The Smallest Change

The restored behavior is delegated to the original Zurk startup script. HA-Chumby does not reimplement the lighttpd command, does not create CGI links, does not modify BusyBox `httpd`, and does not create replacement endpoints.

This preserves the original Zurk startup sequence, including non-web setup steps that were easy to miss during earlier diagnostics.

## Expected Boot Behavior

1. Chumby boots from USB.
2. USB `debugchumby` executes.
3. HA-Chumby `start.sh` starts.
4. HA-Chumby splash screen appears.
5. `start.sh` executes `/mnt/usb/debugchumby.zurk-original`.
6. Original Zurk startup kills BusyBox `httpd`.
7. Original Zurk startup starts lighttpd using `/mnt/usb/lighty/lighttpd.conf`.
8. Diagnostics are copied to `/mnt/usb/ha-chumby/boot-diagnostics.txt`.
9. HA-Chumby remains in the foreground redraw loop.

## Expected Runtime Checks

| Check | Expected result |
| --- | --- |
| `PASS: lighttpd is running` | Expected if Zurk startup succeeds. |
| `FAIL: BusyBox httpd is not running` | Expected if Zurk startup successfully killed BusyBox `httpd`. |
| `PASS: CGI directory exists at /mnt/usb/lighty/cgi-bin` | Expected. |
| `PASS: speak.pl exists at /mnt/usb/lighty/cgi-bin/speak.pl` | Expected. |
| `PASS: lighttpd config exists at /mnt/usb/lighty/lighttpd.conf` | Expected. |

## Manual Validation

After boot, test from a browser or terminal on the same network:

```text
http://<chumby-ip>/
http://<chumby-ip>/cgi-bin/speak.pl?action=say&words=hello
http://<chumby-ip>/cgi-bin/chumote/index.cgi
http://<chumby-ip>/server-status
```

Then remove the USB stick and confirm the Chumby returns to original stock behavior.

## Rollback Procedure

Rollback is USB-only.

1. Power off the Chumby.
2. Remove the USB stick.
3. On a computer, restore the previous `ha-chumby/start.sh` from git or from the previous USB copy.
4. Reinsert the USB stick and boot again.

Removing the USB stick entirely should still restore original internal firmware behavior because Sprint 10 does not modify internal flash.

## Constraints Preserved

Sprint 10 does not:

- modify internal flash
- replace BusyBox `httpd`
- replace firmware
- install software
- rewrite the Zurk runtime
- create replacement CGI scripts
- modify Home Assistant
