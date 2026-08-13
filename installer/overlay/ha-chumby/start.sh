#!/bin/sh
# Persistent HA-Chumby boot confirmation screen with runtime diagnostics.

APP_DIR="$(dirname "$0")"
IMAGE="$APP_DIR/boot-screen.rgb565"
LOG="/tmp/ha-chumby.log"
USB_DIAGNOSTICS="$APP_DIR/boot-diagnostics.txt"
FRAMEBUFFER=""
REDRAW_SECONDS=2

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') start.sh: $*" >> "$LOG"
}

section() {
    echo "" >> "$LOG"
    echo "===== $* =====" >> "$LOG"
}

run_cmd() {
    label="$1"
    shift
    echo "" >> "$LOG"
    echo "--- $label ---" >> "$LOG"
    "$@" >> "$LOG" 2>&1
    status=$?
    echo "--- exit $status: $label ---" >> "$LOG"
    return $status
}

run_shell() {
    label="$1"
    command_text="$2"
    echo "" >> "$LOG"
    echo "--- $label ---" >> "$LOG"
    sh -c "$command_text" >> "$LOG" 2>&1
    status=$?
    echo "--- exit $status: $label ---" >> "$LOG"
    return $status
}

copy_diagnostics_to_usb() {
    if [ -n "$USB_DIAGNOSTICS" ] && [ -d "$APP_DIR" ] && [ -r "$LOG" ]; then
        cp "$LOG" "$USB_DIAGNOSTICS" 2>/dev/null || log "WARNING: failed to copy diagnostics to $USB_DIAGNOSTICS"
        sync 2>/dev/null || true
    fi
}

inspect_lighttpd_configs() {
    section "lighttpd configuration inspection"
    find / -name "lighttpd.conf" 2>/dev/null | while read conf; do
        echo "" >> "$LOG"
        echo "--- lighttpd.conf: $conf ---" >> "$LOG"
        if [ -r "$conf" ]; then
            for pattern in "server.document-root" "cgi.assign" "server.modules" "alias.url" "include"; do
                grep -n "$pattern" "$conf" >> "$LOG" 2>&1
            done
            echo "--- full config follows: $conf ---" >> "$LOG"
            cat "$conf" >> "$LOG" 2>&1
        else
            echo "not readable" >> "$LOG"
        fi
    done
}

inspect_http_file() {
    file_path="$1"
    echo "" >> "$LOG"
    echo "===== BEGIN FILE =====" >> "$LOG"
    echo "$file_path" >> "$LOG"
    ls -l "$file_path" >> "$LOG" 2>&1

    echo "--- cat output ---" >> "$LOG"
    cat "$file_path" >> "$LOG" 2>&1
    cat_status=$?
    echo "--- cat exit $cat_status ---" >> "$LOG"

    if command -v strings >/dev/null 2>&1; then
        echo "--- strings output ---" >> "$LOG"
        strings "$file_path" >> "$LOG" 2>&1
        strings_status=$?
        echo "--- strings exit $strings_status ---" >> "$LOG"
    else
        echo "--- strings unavailable ---" >> "$LOG"
    fi

    echo "===== END FILE =====" >> "$LOG"
}

inspect_http_configs() {
    section "busybox httpd configuration inspection"
    run_shell "find httpd files" 'find / -name "httpd*" 2>/dev/null'
    run_shell "find busybox httpd candidate configs" 'find / -name "httpd.conf" -o -name "httpd.cfg" -o -name "httpd.conf.*" 2>/dev/null'
    find / -name "httpd*" 2>/dev/null | while read conf; do
        inspect_http_file "$conf"
    done
}

inspect_http_runtime() {
    section "http runtime process inspection"
    run_cmd "ps" ps
    run_shell "http related processes" 'ps | grep -i "http"; ps | grep -i "lighty"; ps | grep -i "lighttpd"; ps | grep -i "busybox"'
    run_shell "proc details for http processes" ' for p in /proc/[0-9]*; do pid=${p#/proc/}; cmd=""; if [ -r "$p/cmdline" ]; then cmd=$(tr "\000" " " < "$p/cmdline"); fi; case "$cmd" in *http*|*lighty*|*lighttpd*|*busybox*) echo "### pid $pid"; echo "cmdline=$cmd"; if [ -r "$p/comm" ]; then echo "comm:"; cat "$p/comm"; fi; if [ -L "$p/exe" ]; then ls -la "$p/exe"; fi; if [ -L "$p/cwd" ]; then ls -la "$p/cwd"; fi; if [ -r "$p/environ" ]; then echo "environment:"; tr "\000" "\n" < "$p/environ"; fi ;; esac; done'
}

inspect_document_roots() {
    section "document root and cgi directory inspection"
    run_shell "ls /mnt/usb/www" 'if [ -e /mnt/usb/www ]; then ls -la /mnt/usb/www; else echo "/mnt/usb/www missing"; fi'
    run_shell "ls /mnt/usb/lighty" 'if [ -e /mnt/usb/lighty ]; then ls -la /mnt/usb/lighty; else echo "/mnt/usb/lighty missing"; fi'
    run_shell "ls /mnt/usb/lighty/cgi-bin" 'if [ -e /mnt/usb/lighty/cgi-bin ]; then ls -la /mnt/usb/lighty/cgi-bin; else echo "/mnt/usb/lighty/cgi-bin missing"; fi'
    run_shell "ls /mnt/usb/www/cgi-bin" 'if [ -e /mnt/usb/www/cgi-bin ]; then ls -la /mnt/usb/www/cgi-bin; else echo "/mnt/usb/www/cgi-bin missing"; fi'
    run_shell "find symlinks under /mnt/usb" 'if [ -e /mnt/usb ]; then find /mnt/usb -type l 2>/dev/null | while read link; do ls -la "$link"; done; else echo "/mnt/usb missing"; fi'
    run_shell "ls /psp" 'if [ -e /psp ]; then ls -la /psp; else echo "/psp missing"; fi'
    run_shell "ls /mnt/usb/psp" 'if [ -e /mnt/usb/psp ]; then ls -la /mnt/usb/psp; else echo "/mnt/usb/psp missing"; fi'
    run_shell "readlink -f /psp/httpd.conf" 'if command -v readlink >/dev/null 2>&1; then readlink -f /psp/httpd.conf; echo "readlink exit $?"; else echo "readlink not found"; fi'
}

inspect_busybox_capabilities() {
    section "busybox httpd capabilities"
    run_shell "busybox" 'if command -v busybox >/dev/null 2>&1; then busybox; else echo "busybox not found in PATH"; fi'
    run_shell "busybox httpd --help" 'if command -v busybox >/dev/null 2>&1; then busybox httpd --help; else echo "busybox not found in PATH"; fi'
    run_shell "httpd --help" 'if command -v httpd >/dev/null 2>&1; then httpd --help; else echo "httpd not found in PATH"; fi'
}

inspect_permissions() {
    section "permissions inspection"
    run_shell "directory permissions" 'for d in /mnt/usb/www /mnt/usb/lighty /mnt/usb/lighty/cgi-bin /mnt/usb/www/cgi-bin; do if [ -e "$d" ]; then ls -ld "$d"; else echo "$d missing"; fi; done'
    run_shell "cgi and perl script permissions" 'if [ -e /mnt/usb ]; then find /mnt/usb -name "*.cgi" -o -name "*.pl" 2>/dev/null | while read f; do ls -la "$f"; done; else echo "/mnt/usb missing"; fi'
}

list_startup_paths() {
    section "startup and init scripts"
    run_shell "known startup directories" 'for d in /etc/init.d /etc /etc/rc.d /etc/rcS.d /etc/rc.d/init.d /mnt/usb /mnt/usb/scripts /mnt/usb/ha-chumby /psp /mnt/usb/psp /usr/chumby /usr/chumby/scripts /usr/local /usr/bin /usr/sbin; do if [ -e "$d" ]; then echo "### $d"; ls -la "$d"; fi; done'
    run_shell "debugchumby files" 'find / -name "debugchumby*" 2>/dev/null'
    run_shell "debugchumby file details" 'find / -name "debugchumby*" 2>/dev/null | while read f; do echo "### $f"; ls -la "$f"; if [ -r "$f" ]; then head -n 120 "$f"; fi; done'
    run_shell "service control scripts" 'find / -name "*lighttpd*" -o -name "*httpd*" -o -name "*control_panel*" 2>/dev/null'
    run_shell "startup scripts referencing httpd" 'for d in /etc/init.d /etc /usr/chumby /usr/chumby/scripts /usr/local /usr/bin /usr/sbin /mnt/usb /mnt/usb/scripts /mnt/usb/ha-chumby; do if [ -e "$d" ]; then find "$d" -type f 2>/dev/null | while read f; do if grep -q "httpd" "$f" 2>/dev/null || grep -q "lighttpd" "$f" 2>/dev/null || grep -q "lighty" "$f" 2>/dev/null; then echo "### $f"; ls -la "$f"; grep -n "httpd" "$f" 2>/dev/null; grep -n "lighttpd" "$f" 2>/dev/null; grep -n "lighty" "$f" 2>/dev/null; fi; done; fi; done'
}

run_diagnostics() {
    : > "$LOG"
    section "ha-chumby sprint 9 boot diagnostics"
    log "diagnostics started"
    log "invoked as: $0"
    log "APP_DIR=$APP_DIR"
    log "USB_DIAGNOSTICS=$USB_DIAGNOSTICS"
    log "PATH=$PATH"

    section "system"
    run_cmd "date" date
    run_cmd "uname -a" uname -a
    run_cmd "cat /proc/cmdline" cat /proc/cmdline
    run_cmd "mount" mount
    run_cmd "df -h" df -h
    run_cmd "env" env
    run_cmd "ps" ps

    section "network"
    run_shell "ifconfig" 'if command -v ifconfig >/dev/null 2>&1; then ifconfig; else echo "ifconfig not found"; fi'
    run_shell "route" 'if command -v route >/dev/null 2>&1; then route; else echo "route not found"; fi'
    run_shell "netstat -ln" 'if command -v netstat >/dev/null 2>&1; then netstat -ln; else echo "netstat not found"; fi'

    section "filesystem discovery"
    run_shell "find lighttpd.conf" 'find / -name "lighttpd.conf" 2>/dev/null'
    run_shell "find httpd files" 'find / -name "httpd*" 2>/dev/null'
    run_shell "find *.cgi" 'find / -name "*.cgi" 2>/dev/null'
    run_shell "find *.pl" 'find / -name "*.pl" 2>/dev/null'
    run_shell "find index.html" 'find / -name "index.html" 2>/dev/null'
    run_shell "find www directories" 'find / -name "www" -type d 2>/dev/null'
    run_shell "find cgi-bin directories" 'find / -name "cgi-bin" -type d 2>/dev/null'

    inspect_http_runtime
    inspect_http_configs
    inspect_document_roots
    inspect_busybox_capabilities
    inspect_permissions
    list_startup_paths
    inspect_lighttpd_configs

    section "diagnostics complete"
    log "diagnostics completed"
    copy_diagnostics_to_usb
}

find_framebuffer() {
    for fb in /dev/fb0 /dev/fb; do
        if [ -e "$fb" ] && [ -w "$fb" ]; then
            FRAMEBUFFER="$fb"
            return 0
        fi
    done
    return 1
}

stop_stock_ui_if_running() {
    if command -v stop_control_panel >/dev/null 2>&1; then
        log "calling stop_control_panel"
        stop_control_panel >> "$LOG" 2>&1 || log "stop_control_panel returned non-zero"
    elif [ -x /usr/chumby/scripts/stop_control_panel ]; then
        log "calling /usr/chumby/scripts/stop_control_panel"
        /usr/chumby/scripts/stop_control_panel >> "$LOG" 2>&1 || log "/usr/chumby/scripts/stop_control_panel returned non-zero"
    else
        log "stop_control_panel not found"
    fi
    copy_diagnostics_to_usb
}

write_screen() {
    if [ -n "$FRAMEBUFFER" ] && [ -r "$IMAGE" ]; then
        cat "$IMAGE" > "$FRAMEBUFFER"
        return $?
    fi
    return 1
}

run_diagnostics

log "starting HA-Chumby persistent boot screen"
log "APP_DIR=$APP_DIR"
log "IMAGE=$IMAGE"

if [ ! -r "$IMAGE" ]; then
    log "ERROR: boot screen image not readable"
else
    log "boot screen image found"
fi

stop_stock_ui_if_running

if find_framebuffer; then
    log "using framebuffer $FRAMEBUFFER"
else
    log "ERROR: no writable framebuffer found"
fi

if write_screen; then
    log "initial boot screen written"
else
    log "ERROR: initial boot screen write failed"
fi

log "entering persistent foreground redraw loop"
copy_diagnostics_to_usb
while true; do
    write_screen || log "ERROR: redraw failed"
    sleep "$REDRAW_SECONDS"
done