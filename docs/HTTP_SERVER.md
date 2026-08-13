# HTTP Server Runtime

Status: Sprint 9 runtime analysis document.

Real hardware behavior is the source of truth for this document. Sprint 5 described endpoints discovered from the extracted Zurk Offline Firmware USB filesystem, but Sprint 8 and Sprint 9 hardware validation show that the active HTTP runtime is different from that extracted-file assumption.

## Confirmed Runtime Architecture

| Layer | Confirmed fact | Evidence |
| --- | --- | --- |
| Boot hook | The USB `debugchumby` path executes. | Hardware validation from previous sprints. |
| HA-Chumby startup | `installer/overlay/ha-chumby/start.sh` executes. | Hardware validation from previous sprints. |
| Display | Direct framebuffer output works. | Hardware validation from previous sprints. |
| Network | The Chumby obtains a DHCP address. | Hardware validation before Sprint 9. |
| HTTP server | BusyBox `httpd` is running and port 80 is open. | Hardware validation before Sprint 9. |
| Internal flash | Internal flash remains untouched. | Removing USB restores original behavior. |

## Confirmed HTTP Behavior

| Request | Result | Meaning |
| --- | --- | --- |
| `GET /` | HTTP 404 | The active document root does not expose the expected Zurk root page. |
| `GET /index.html` | HTTP 404 | The expected `index.html` is not reachable from the active root. |
| `GET /cgi-bin/` | HTTP 403 | A protected path exists or directory listing is denied; this does not prove Zurk CGI is active. |
| `GET /cgi-bin/speak.pl` | HTTP 404 | The expected Zurk TTS CGI script is not reachable through the active CGI path. |

## Working Runtime Hypothesis

Current hardware evidence indicates:

| Runtime item | Current understanding | Confidence |
| --- | --- | --- |
| HTTP daemon | BusyBox `httpd` | Confirmed by hardware validation. |
| Document root | Appears to be `/mnt/usb/www` | Reported from boot diagnostics; Sprint 9 diagnostics collect stronger evidence. |
| Zurk CGI location | `/mnt/usb/lighty/cgi-bin` | Confirmed from USB filesystem inventory and boot diagnostics summary. |
| CGI reachability | Not reachable at `/cgi-bin/speak.pl` | Confirmed by HTTP 404. |
| Likely mismatch | HTTP root is `/mnt/usb/www` while CGI files are under `/mnt/usb/lighty/cgi-bin` | Likely, pending Sprint 9 detailed diagnostics. |

## Sprint 9 Diagnostics

`installer/overlay/ha-chumby/start.sh` now collects additional passive diagnostics at every boot.

Logs are written to:

```text
/tmp/ha-chumby.log
```

and copied to the USB stick as:

```text
/ha-chumby/boot-diagnostics.txt
```

The diagnostics do not modify internal flash, replace BusyBox `httpd`, start services, add symlinks, repair CGI, install software, add Python, or implement Home Assistant.

## HTTP Server Process Evidence

Sprint 9 diagnostics capture:

| Evidence | Purpose |
| --- | --- |
| `ps` | Identify the HTTP server process. |
| HTTP-related process grep output | Locate `httpd`, `lighty`, `lighttpd`, or `busybox` process lines. |
| `/proc/<pid>/cmdline` | Determine executable name and startup arguments. |
| `/proc/<pid>/comm` | Determine kernel process name. |
| `/proc/<pid>/exe` symlink | Determine executable path when available. |
| `/proc/<pid>/cwd` symlink | Determine working directory when available. |
| `/proc/<pid>/environ` | Record runtime environment where readable. |

## Configuration Discovery

Sprint 9 diagnostics search for:

```text
find / -name "httpd*" 2>/dev/null
find / -name "httpd.conf" -o -name "httpd.cfg" -o -name "httpd.conf.*" 2>/dev/null
```

For every path returned by `find / -name "httpd*"`, the diagnostics log:

- `===== BEGIN FILE =====`
- full path
- `ls -l` output
- complete `cat` output with stderr captured
- `cat` exit code
- `strings` output and exit code when the `strings` command is available
- `===== END FILE =====`

This is intentionally broader than only dumping `httpd.conf` because the running hardware already revealed `/psp/httpd.conf`, and BusyBox `httpd` may be started from a path or wrapper that was not captured by the narrower Sprint 9 search.

The diagnostics continue to inspect discovered `lighttpd.conf` files because Sprint 5 found a Zurk lighttpd tree, but the active server is currently known to be BusyBox `httpd`.

## Document Root And CGI Inspection

Sprint 9 diagnostics log `ls -la` for:

```text
/mnt/usb/www
/mnt/usb/lighty
/mnt/usb/lighty/cgi-bin
/mnt/usb/www/cgi-bin
/psp
/mnt/usb/psp
```

When `readlink` is available, diagnostics also run:

```text
readlink -f /psp/httpd.conf
```

They also run:

```text
find /mnt/usb -type l
```

This determines whether `/mnt/usb/www/cgi-bin` exists, whether it is a symlink, and whether any link points from the active BusyBox document root to the Zurk CGI directory.

## BusyBox HTTP Capabilities

Sprint 9 diagnostics capture complete output for:

```text
busybox
busybox httpd --help
httpd --help
```

This is needed because BusyBox `httpd` CGI behavior depends on build options and startup flags. Sprint 10 should use the captured help output rather than assuming desktop BusyBox behavior.

## Permissions Inspection

Sprint 9 diagnostics log permissions for:

```text
/mnt/usb/www
/mnt/usb/lighty
/mnt/usb/lighty/cgi-bin
/mnt/usb/www/cgi-bin
```

and all discovered:

```text
*.cgi
*.pl
```

under `/mnt/usb`.

## Startup Sequence Discovery

Sprint 9 diagnostics inspect these locations when present:

```text
/etc/init.d
/etc
/usr/chumby
/usr/chumby/scripts
/usr/local
/usr/bin
/usr/sbin
/mnt/usb
/mnt/usb/scripts
/mnt/usb/ha-chumby
```

They record:

- directory listings
- discovered `debugchumby*` files
- first 120 lines of readable `debugchumby*` files
- discovered `httpd`, `lighttpd`, `lighty`, and `control_panel` related paths
- startup scripts containing `httpd`, `lighttpd`, or `lighty`

## Comparison With Sprint 5

| Sprint 5 assumption | Sprint 9 status | Notes |
| --- | --- | --- |
| Zurk lighttpd configuration under `/mnt/usb/lighty/lighttpd.conf` defines the active server. | Incorrect for the current boot, unless Sprint 9 diagnostics prove otherwise. | Hardware shows BusyBox `httpd`, not reachable Zurk lighttpd endpoints. |
| Document root is `/mnt/usb/lighty/html`. | Likely incorrect at runtime. | Current evidence says active root appears to be `/mnt/usb/www`. |
| `/cgi-bin/` maps to `/mnt/usb/lighty/cgi-bin/`. | Incorrect or incomplete at runtime. | `/cgi-bin/speak.pl` returns 404 even though Zurk CGI files exist under `/mnt/usb/lighty/cgi-bin`. |
| Zurk CGI files can be called directly from Home Assistant. | Incorrect for the current runtime. | Sprint 7 package depends on endpoints that are not reachable yet. |
| Zurk endpoint inventory remains useful. | Correct as a capability inventory, not as active runtime proof. | The files still identify reusable behavior once CGI reachability is restored. |

## Open Questions

| Question | Evidence needed |
| --- | --- |
| Which exact `httpd` command line is active? | Sprint 9 `/proc/<pid>/cmdline` output. |
| Is BusyBox `httpd` using a config file or only command-line flags? | Process arguments and discovered `httpd*` files. |
| What exact document root was passed to `httpd`? | Process arguments and BusyBox help semantics. |
| Is `/mnt/usb/www/cgi-bin` missing, empty, non-executable, or not configured? | Directory listing, symlink listing, permissions. |
| Does the BusyBox build support CGI execution? | `busybox httpd --help` and `httpd --help` output. |
| Which startup script starts BusyBox `httpd`? | Startup script scans and process parentage if visible. |
| Should Sprint 10 link/copy CGI into `/mnt/usb/www/cgi-bin` or start the original Zurk runtime differently? | Only after the active command line and BusyBox CGI semantics are known. |

## Non-Goals

Sprint 9 does not repair CGI reachability. It does not create symlinks, copy CGI files, modify startup scripts other than diagnostics, install software, replace BusyBox `httpd`, start lighttpd, or implement Home Assistant.

