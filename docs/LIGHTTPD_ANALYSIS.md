# lighttpd Analysis

Status: Sprint 8 lighttpd runtime analysis document.

Earlier Sprint 5 inventory found a Zurk Offline Firmware lighttpd configuration in the extracted USB filesystem. Hardware testing now shows port 80 is open, but the expected Zurk endpoints return 404 or 403. This document defines how to identify the active lighttpd runtime from the Chumby itself.

## Known Request Behavior

| Request | Observed result | Meaning |
| --- | --- | --- |
| `GET /` | HTTP 404 | The expected Zurk web root is not being served. |
| `GET /index.html` | HTTP 404 | The expected Zurk `index.html` is not in the active document root, or a different HTTP configuration is active. |
| `GET /cgi-bin/` | HTTP 403 | A protected directory or CGI path may exist, but directory listing is forbidden. |
| `GET /cgi-bin/speak.pl` | HTTP 404 | The expected Zurk TTS CGI endpoint is not active at that path. |

## Previously Inventoried Zurk Configuration

Sprint 5 inspected `E:\lighty\lighttpd.conf` on the prepared USB stick. That file indicated the intended Zurk runtime shape.

| Directive | Previously inventoried value | Source |
| --- | --- | --- |
| `server.document-root` | `/mnt/usb/lighty/html` | `docs/API.md`, `E:\lighty\lighttpd.conf` |
| `/cgi-bin/` alias | `/mnt/usb/lighty/cgi-bin/` | `docs/API.md`, `E:\lighty\lighttpd.conf` |
| CGI shell interpreter | `.sh` and `.cgi` assigned to `/bin/sh` | `docs/API.md`, `E:\lighty\lighttpd.conf` |
| CGI Perl interpreter | `.pl` assigned to `/mnt/usb/perl/perl` | `docs/API.md`, `E:\lighty\lighttpd.conf` |
| Status endpoint | `/server-status` | `docs/API.md`, `E:\lighty\lighttpd.conf` |

These values are not assumed to be active after boot. They are comparison points for the real diagnostic log.

## Boot Diagnostic Extraction

`installer/overlay/ha-chumby/start.sh` records every discovered `lighttpd.conf` file and logs:

- full path
- matching directive lines for `server.document-root`
- matching directive lines for `cgi.assign`
- matching directive lines for `server.modules`
- matching directive lines for `alias.url`
- matching directive lines for `include`
- full file contents

The log location on the USB stick is:

```text
/ha-chumby/boot-diagnostics.txt
```

## Analysis Procedure

1. Search the boot diagnostics for `===== lighttpd configuration inspection =====`.
2. List every `--- lighttpd.conf:` block.
3. Search the `ps` output for `lighttpd`, `httpd`, or another web server process.
4. If the process line includes `-f`, record the config path after `-f` as the active config.
5. If the process line does not include a config path, compare process name and startup scripts to determine the default config path.
6. Read `server.document-root` from the active config.
7. Read `alias.url` from the active config and identify the active CGI directory.
8. Read `cgi.assign` from the active config and confirm `.pl`, `.sh`, and `.cgi` handling.
9. Compare active values with the previously inventoried Zurk values.
10. Document any mismatch in the Findings table below.

## Findings

| Question | Measured answer | Evidence from `boot-diagnostics.txt` |
| --- | --- | --- |
| Which HTTP daemon is active? | Pending hardware log | Pending hardware log |
| Which lighttpd configuration is active? | Pending hardware log | Pending hardware log |
| Which document root is active? | Pending hardware log | Pending hardware log |
| Which CGI alias is active? | Pending hardware log | Pending hardware log |
| Is `.pl` CGI execution configured? | Pending hardware log | Pending hardware log |
| Is `.sh` CGI execution configured? | Pending hardware log | Pending hardware log |
| Is `/mnt/usb/lighty/html/index.html` present at runtime? | Pending hardware log | Pending hardware log |
| Is `/mnt/usb/lighty/cgi-bin/speak.pl` present at runtime? | Pending hardware log | Pending hardware log |
| Is the active config the Zurk USB config? | Pending hardware log | Pending hardware log |

## Service Gap Matrix

| Expected Zurk service | Evidence needed | Status |
| --- | --- | --- |
| USB lighttpd using `/mnt/usb/lighty/lighttpd.conf` | `ps`, lighttpd config block | Pending hardware log |
| Web root `/mnt/usb/lighty/html` | active `server.document-root` | Pending hardware log |
| CGI alias `/cgi-bin/` to `/mnt/usb/lighty/cgi-bin/` | active `alias.url` | Pending hardware log |
| Perl CGI for `speak.pl` | active `cgi.assign`, presence of `/mnt/usb/perl/perl` | Pending hardware log |
| Shell CGI for Zurk control scripts | active `cgi.assign`, presence of CGI files | Pending hardware log |

## Conditional Restoration Notes

No restoration implementation has been made yet. The smallest possible future change must be chosen only after the active runtime is known.

| Confirmed diagnostic result | Smallest change to consider later |
| --- | --- |
| USB Zurk config exists but no process uses it | Start the original Zurk lighttpd service using the original USB config path. |
| Original Zurk `debugchumby` contains the missing service startup sequence | Chain or source the original Zurk startup step before entering the HA-Chumby foreground loop, preserving the overlay. |
| Active config points to a stock/internal document root | Switch startup to the original Zurk service startup path rather than editing internal flash or creating replacement endpoints. |
| Files are missing from the USB runtime | Update USB preparation documentation and installer copy behavior; do not compensate by creating replacement CGI scripts. |

## Non-Goals

This sprint does not:

- replace lighttpd
- install a new web server
- create a project-owned CGI tree
- create a custom REST API
- modify internal flash
- implement Home Assistant integration
