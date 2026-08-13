# Sprint 10 Implementation

Status: Sprint 10 original-runtime restoration implementation.

## Implementation Summary

`installer/overlay/ha-chumby/start.sh` is now a finite boot overlay. It displays the HA-Chumby splash, waits about 3 seconds, restores the original Zurk startup, logs diagnostics, and exits so the normal Chumby runtime can continue.

## Runtime Changes

| Area | Change |
| --- | --- |
| Splash behavior | Splash appears briefly instead of being redrawn forever. |
| Zurk startup | `start.sh` runs `/mnt/usb/debugchumby.zurk-original` when available. |
| Fallback startup | `start.sh` runs `/mnt/usb/lighty/startup.sh` only when the preserved original hook is missing. |
| Original runtime | `start.sh` exits with status 0 so the startup sequence that invoked USB `debugchumby` can continue. |
| Diagnostics | Logs process snapshots, listening ports, exit codes, runtime file checks, and framebuffer clues. |

## Expected Behaviour

1. Chumby boots from USB.
2. USB `debugchumby` executes.
3. HA-Chumby splash appears.
4. The splash remains for about 3 seconds.
5. Zurk startup runs from USB.
6. HA-Chumby exits.
7. Original Chumby UI appears. Sprint 11 requires the USB PSP configured-state marker `/psp/firsttime=0` so this does not enter factory setup.
8. Widget engine starts.
9. Chumote `event.cgi` commands affect the running device.

## Why The Persistent Loop Was Removed

The persistent loop kept the splash visible, but hardware validation showed that the original Chumby interface never started and Chumote event commands had no visible effect. That made HA-Chumby a replacement runtime, which is not the project goal.

The smallest fix is to stop holding the foreground after the splash and let the original startup continue.

## Rollback Procedure

Rollback is USB-only.

1. Power off the Chumby.
2. Remove the USB stick.
3. Restore the previous `ha-chumby/start.sh` from git or rerun the installer from the desired branch.
4. Reinsert the USB stick and boot again.

Removing the USB stick entirely should still restore original internal firmware behavior because Sprint 10 does not modify internal flash.

## Constraints Preserved

Sprint 10 does not:

- modify internal flash
- replace BusyBox `httpd`
- replace Zurk
- replace the widget engine
- create replacement CGI scripts
- modify Home Assistant
- implement alarms
