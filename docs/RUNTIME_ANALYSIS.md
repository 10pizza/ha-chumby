# Runtime Analysis

Status: Sprint 8 runtime discovery document.

This sprint treats measured behavior on the Chumby Classic hardware as the source of truth. Earlier documentation based on extracted Zurk Offline Firmware files is useful background, but it must not override the active runtime observed after USB boot.

## Current Hardware Evidence

| Observation | Result | Interpretation |
| --- | --- | --- |
| USB boot path | Works | `debugchumby` is executed from USB and the HA-Chumby overlay starts. |
| Internal flash | Unmodified | Removing the USB stick restores stock behavior. |
| Framebuffer write | Works | `installer/overlay/ha-chumby/start.sh` can draw the HA-Chumby boot screen. |
| Network stack | Starts | Hardware validation observed DHCP address assignment. |
| TCP port 80 | Open | A web server is running on the device. |
| `GET /` | HTTP 404 | The active document root does not serve the expected Zurk root page, or a different server/configuration is active. |
| `GET /index.html` | HTTP 404 | The active document root does not contain the expected `index.html`, or the request is not reaching the Zurk document root. |
| `GET /cgi-bin/` | HTTP 403 | A CGI directory or protected directory may exist, but directory listing is forbidden. This does not prove the Zurk CGI tree is active. |
| `GET /cgi-bin/speak.pl` | HTTP 404 | The active CGI path does not expose the expected Zurk `speak.pl` endpoint. |

## Source Of Truth Rule

The runtime diagnostics collected from real hardware at `/ha-chumby/boot-diagnostics.txt` take precedence over:

- `docs/API.md`
- `docs/MVP_MAPPING.md`
- extracted USB filesystem inventory
- assumptions about Zurk startup behavior

If the boot diagnostics contradict earlier documentation, update the earlier documentation after reviewing the log.

## Diagnostic Instrumentation

`installer/overlay/ha-chumby/start.sh` now executes a temporary diagnostics pass automatically at boot.

The diagnostics write to:

```text
/tmp/ha-chumby.log
```

The same log is copied to the USB stick so it survives reboot and power-off:

```text
/ha-chumby/boot-diagnostics.txt
```

The diagnostics do not install software, modify internal flash, replace lighttpd, create a new web server, create CGI scripts, or start Home Assistant integration code.

## Collected Data

| Area | Commands or probes |
| --- | --- |
| System | `date`, `uname -a`, `cat /proc/cmdline`, `mount`, `df -h`, `env`, `ps` |
| Network | `ifconfig`, `route`, `netstat -ln` when available |
| Filesystem | `find / -name "lighttpd.conf"`, `find / -name "*.cgi"`, `find / -name "*.pl"`, `find / -name "index.html"`, `find / -name "www" -type d`, `find / -name "cgi-bin" -type d` |
| Startup | Listings for known init/startup locations, discovered `debugchumby*` files, readable `debugchumby*` headers, and lighttpd/httpd/control-panel related scripts |
| lighttpd | Every discovered `lighttpd.conf`, including selected directives and the full file contents |

## Questions To Answer From The Real Boot Log

| Question | Evidence to use | Status |
| --- | --- | --- |
| Which filesystem is active as root? | `mount`, `df -h`, `/proc/cmdline` | Pending hardware log |
| Where is the USB stick mounted? | `mount`, `df -h`, `APP_DIR` | Pending hardware log |
| Which startup sequence executes `debugchumby`? | `ps`, discovered init scripts, discovered `debugchumby*` files, log `invoked as` line | Pending hardware log |
| Is the original Zurk `debugchumby` still present and callable? | `find / -name "debugchumby*"`, startup directory listings | Pending hardware log |
| Which HTTP daemon is listening on port 80? | `ps`, `netstat -ln`, discovered service scripts | Pending hardware log |
| Which `lighttpd.conf` is active? | `ps` command arguments, discovered configs, `lighttpd.conf` content | Pending hardware log |
| Which document root is active? | Active lighttpd configuration and request behavior | Pending hardware log |
| Which CGI directory is active? | Active lighttpd aliases and CGI assignment | Pending hardware log |
| Is the Zurk runtime started? | `ps`, mounted paths, presence of `/mnt/usb/lighty`, active document root, active CGI alias | Pending hardware log |
| Which services are missing compared to the original runtime? | Compare active runtime to `docs/API.md` and `docs/MVP_MAPPING.md` after diagnostics are collected | Pending hardware log |

## Restoration Hypotheses

These are hypotheses only. Do not implement them until `/ha-chumby/boot-diagnostics.txt` proves which case is true.

| Evidence from diagnostics | Likely cause | Smallest possible documented change to consider later |
| --- | --- | --- |
| Port 80 is served by stock/internal lighttpd and not the USB Zurk lighttpd configuration. | The HA-Chumby replacement `debugchumby` starts the boot screen but does not continue the original Zurk runtime startup path. | Chain to the original Zurk `debugchumby` startup logic before entering the HA-Chumby foreground loop, or invoke only the missing original service startup script if clearly identified. |
| `/mnt/usb/lighty/lighttpd.conf` exists but no lighttpd process uses it. | USB runtime files are present but the Zurk web service is not started. | Start the original Zurk lighttpd command with the USB config exactly as the original script would, without replacing lighttpd or creating a new server. |
| Active lighttpd uses a document root other than `/mnt/usb/lighty/html`. | A different configuration is active. | Adjust the startup sequence to use the original Zurk lighttpd configuration, not a project-created config. |
| Active lighttpd uses `/mnt/usb/lighty/html` but `/cgi-bin/speak.pl` is 404. | CGI alias or USB file mount may be missing/incomplete. | Restore the original Zurk CGI alias/startup path or fix USB preparation documentation if files are absent. |
| `/mnt/usb/lighty` is missing at runtime. | USB mount path differs, firmware files were not copied, or the boot environment exposes a different mount point. | Update installer and documentation to use the measured mount path; do not hard-code `/mnt/usb` until verified. |

## No Implementation Decision Yet

Sprint 8 has not yet identified the missing startup step from real diagnostics. Therefore no service restoration change is implemented in this sprint branch beyond diagnostics.

The next action on hardware is:

1. Copy the updated overlay to the USB stick.
2. Boot the Chumby.
3. Wait for the HA-Chumby screen.
4. Power off or remove the USB stick after the log has been copied.
5. Read `/ha-chumby/boot-diagnostics.txt` from the USB stick on a computer.
6. Update this document with measured results.

