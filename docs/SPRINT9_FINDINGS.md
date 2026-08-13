# Sprint 9 Findings

Status: Sprint 9 analysis document.

This document records what is currently known from real hardware and what Sprint 9 diagnostics are designed to prove before Sprint 10 changes runtime behavior.

## Confirmed Facts

| Fact | Evidence |
| --- | --- |
| USB boot works. | Previous hardware validation. |
| USB `debugchumby` executes. | Previous hardware validation. |
| `installer/overlay/ha-chumby/start.sh` executes. | Previous hardware validation. |
| Custom framebuffer output works. | Previous hardware validation. |
| Internal flash remains untouched. | Removing the USB stick restores original behavior. |
| Networking works and DHCP assigns an address. | Hardware validation before Sprint 9. |
| Port 80 is open. | Hardware validation before Sprint 9. |
| BusyBox `httpd` is running. | Hardware validation before Sprint 9. |
| `GET /` returns HTTP 404. | Hardware validation before Sprint 9. |
| `GET /index.html` returns HTTP 404. | Hardware validation before Sprint 9. |
| `GET /cgi-bin/` returns HTTP 403. | Hardware validation before Sprint 9. |
| `GET /cgi-bin/speak.pl` returns HTTP 404. | Hardware validation before Sprint 9. |
| The active runtime contradicts the Sprint 5 assumption that Zurk lighttpd endpoints are directly reachable. | Comparison of HTTP results with `docs/API.md`. |
| Zurk CGI scripts exist under `/mnt/usb/lighty/cgi-bin`. | Sprint 5 USB inventory and Sprint 8 diagnostic summary. |
| The active document root appears to be `/mnt/usb/www`. | Sprint 8 diagnostic summary; Sprint 9 collects stronger evidence. |

## Rejected Hypotheses

| Hypothesis | Status | Reason |
| --- | --- | --- |
| Networking is down. | Rejected. | Device receives DHCP address and port 80 is open. |
| No HTTP server is running. | Rejected. | BusyBox `httpd` is running and returns HTTP status codes. |
| Home Assistant caused the issue. | Rejected. | The 404/403 behavior occurs through direct HTTP requests before relying on HA control. |
| The Chumby cannot serve HTTP after USB boot. | Rejected. | BusyBox `httpd` is serving responses. |
| The issue is simply that `/cgi-bin/` directory listing is forbidden. | Rejected as complete explanation. | `/cgi-bin/` returning 403 may be normal, but `/cgi-bin/speak.pl` returning 404 shows the expected CGI file is not reachable at that path. |
| Sprint 5 extracted-file inventory proves active runtime paths. | Rejected. | Runtime behavior shows BusyBox `httpd` with a likely different document root. |

## Likely Root Cause

The likely root cause is a document-root and CGI-path mismatch:

```text
active HTTP document root: appears to be /mnt/usb/www
Zurk CGI scripts:          /mnt/usb/lighty/cgi-bin
expected URL path:         /cgi-bin/speak.pl
actual result:             HTTP 404
```

This suggests that BusyBox `httpd` is serving `/mnt/usb/www` while the Zurk CGI scripts remain outside the active CGI directory. If `/mnt/usb/www/cgi-bin` is missing, empty, not a symlink, or not configured for CGI execution, `/cgi-bin/speak.pl` will not resolve to `/mnt/usb/lighty/cgi-bin/speak.pl`.

This is still a hypothesis until Sprint 9 diagnostics capture the exact `httpd` command line, configuration files, directory listings, symlinks, permissions, and BusyBox `httpd` capabilities from the running Chumby.

## Missing Information

| Missing information | Sprint 9 diagnostic source |
| --- | --- |
| Exact BusyBox `httpd` command line. | `/proc/<pid>/cmdline` in `/ha-chumby/boot-diagnostics.txt`. |
| Exact executable path. | `/proc/<pid>/exe` in diagnostics. |
| Process working directory. | `/proc/<pid>/cwd` in diagnostics. |
| Whether a config file is used. | Process arguments plus complete dumps of every path returned by `find / -name "httpd*"`. |
| Exact active document root. | Process arguments, config contents, `/psp` listing, `/mnt/usb/psp` listing, `readlink -f /psp/httpd.conf`, and `/mnt/usb/www` listing. |
| Whether `/mnt/usb/www/cgi-bin` exists. | Directory listing in diagnostics. |
| Whether any symlink maps `/mnt/usb/www/cgi-bin` to `/mnt/usb/lighty/cgi-bin`. | `find /mnt/usb -type l`. |
| Whether BusyBox `httpd` supports CGI in this build. | `busybox httpd --help`, `httpd --help`, and `strings` output from discovered `httpd*` binaries/config files. |
| Which startup script launches `httpd`. | Startup script scan for `httpd`, `lighttpd`, and `lighty`. |

## Recommended Sprint 10 Implementation

Do not implement any of these until the Sprint 9 boot log confirms the active runtime.

| Confirmed Sprint 9 finding | Smallest Sprint 10 change to consider |
| --- | --- |
| BusyBox `httpd` serves `/mnt/usb/www` and supports CGI from `cgi-bin`. | Add or restore a USB-side `/mnt/usb/www/cgi-bin` link to `/mnt/usb/lighty/cgi-bin`, if symlink support and path semantics are confirmed. |
| BusyBox `httpd` serves `/mnt/usb/www` but does not support CGI in the active mode. | Start BusyBox `httpd` with the original supported CGI flags if documented by runtime help and startup scripts. |
| BusyBox `httpd` is a minimal stock server and Zurk intended lighttpd to serve the reusable endpoints. | Restore the original Zurk service startup path instead of creating replacement endpoints. |
| Original Zurk `debugchumby` contains the missing service startup step. | Chain the original Zurk startup step before the HA-Chumby foreground loop, preserving the HA-Chumby overlay. |
| CGI files are present but not executable. | Fix USB-side permissions during USB preparation only, without modifying internal flash. |
| CGI files are absent from the USB at runtime. | Fix the USB preparation process/documentation so the original Zurk files are present; do not create replacement CGI scripts. |

## Sprint 10 Guardrails

The Sprint 10 fix should be the smallest change that restores the original Zurk runtime behavior. It should not:

- modify internal flash
- replace BusyBox `httpd`
- replace the web server
- create replacement CGI scripts
- create a custom REST server
- add Python
- implement Home Assistant logic
- move away from the existing firmware endpoints unless diagnostics prove they cannot be restored

## Documentation Updates From Sprint 9

| Document | Update |
| --- | --- |
| `docs/API.md` | Add runtime warning that Sprint 5 endpoint inventory is not currently reachable on hardware. |
| `docs/MVP_MAPPING.md` | Add runtime warning that firmware endpoint reuse is blocked until CGI reachability is restored. |
| `docs/HTTP_SERVER.md` | New detailed runtime analysis guide. |
| `docs/SPRINT9_FINDINGS.md` | New findings and Sprint 10 recommendation record. |

