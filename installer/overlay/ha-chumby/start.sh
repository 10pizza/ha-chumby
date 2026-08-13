#!/bin/sh
# Persistent HA-Chumby boot confirmation screen with Zurk web runtime restoration.

APP_DIR="$(dirname "$0")"
IMAGE="$APP_DIR/boot-screen.rgb565"
LOG="/tmp/ha-chumby.log"
USB_DIAGNOSTICS="$APP_DIR/boot-diagnostics.txt"
USB_ROOT="/mnt/usb"
ZURK_ORIGINAL="$USB_ROOT/debugchumby.zurk-original"
ZURK_STARTUP="$USB_ROOT/lighty/startup.sh"
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

find_framebuffer() {
    for fb in /dev/fb0 /dev/fb; do
        if [ -e "$fb" ] && [ -w "$fb" ]; then
            FRAMEBUFFER="$fb"
            return 0
        fi
    done
    return 1
}

write_screen() {
    if [ -n "$FRAMEBUFFER" ] && [ -r "$IMAGE" ]; then
        cat "$IMAGE" > "$FRAMEBUFFER"
        return $?
    fi
    return 1
}

initial_diagnostics() {
    section "ha-chumby sprint 10 startup"
    log "startup diagnostics started"
    log "invoked as: $0"
    log "APP_DIR=$APP_DIR"
    log "USB_ROOT=$USB_ROOT"
    log "USB_DIAGNOSTICS=$USB_DIAGNOSTICS"
    log "ZURK_ORIGINAL=$ZURK_ORIGINAL"
    log "ZURK_STARTUP=$ZURK_STARTUP"
    log "PATH=$PATH"

    section "system before zurk startup"
    run_cmd "date" date
    run_cmd "uname -a" uname -a
    run_cmd "cat /proc/cmdline" cat /proc/cmdline
    run_cmd "mount" mount
    run_cmd "df -h" df -h
    run_cmd "ps before zurk startup" ps
    run_shell "listening ports before zurk startup" 'if command -v netstat >/dev/null 2>&1; then netstat -ln; else echo "netstat not found"; fi'
}

show_splash() {
    section "ha-chumby splash"
    if [ ! -r "$IMAGE" ]; then
        log "ERROR: boot screen image not readable"
    else
        log "boot screen image found"
    fi

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
    copy_diagnostics_to_usb
}

restore_zurk_runtime() {
    section "restore original zurk runtime"

    if [ -r "$ZURK_ORIGINAL" ]; then
        log "executing original Zurk startup: $ZURK_ORIGINAL"
        sh "$ZURK_ORIGINAL" >> "$LOG" 2>&1
        status=$?
        log "original Zurk startup exit code: $status"
        copy_diagnostics_to_usb
        return $status
    fi

    log "original Zurk startup not found at $ZURK_ORIGINAL"
    if [ -r "$ZURK_STARTUP" ]; then
        log "executing Zurk web-service startup fallback: $ZURK_STARTUP"
        sh "$ZURK_STARTUP" >> "$LOG" 2>&1
        status=$?
        log "Zurk web-service startup fallback exit code: $status"
        copy_diagnostics_to_usb
        return $status
    fi

    log "ERROR: no Zurk startup script found; runtime not restored"
    copy_diagnostics_to_usb
    return 1
}

post_startup_diagnostics() {
    section "system after zurk startup"
    run_cmd "ps after zurk startup" ps
    run_shell "listening ports after zurk startup" 'if command -v netstat >/dev/null 2>&1; then netstat -ln; else echo "netstat not found"; fi'
    run_shell "http related processes after zurk startup" 'ps | grep -i "http"; ps | grep -i "lighty"; ps | grep -i "lighttpd"; ps | grep -i "busybox"'
    run_shell "lighttpd output marker" 'if [ -e /mnt/usb/tmp/write.ok ]; then ls -l /mnt/usb/tmp/write.ok; cat /mnt/usb/tmp/write.ok; else echo "/mnt/usb/tmp/write.ok missing"; fi'
}

validate_runtime() {
    section "runtime validation"

    if ps | grep -i "[l]ighttpd" >/dev/null 2>&1; then
        log "PASS: lighttpd is running"
    else
        log "FAIL: lighttpd is not running"
    fi

    if ps | grep -i "[h]ttpd" >/dev/null 2>&1; then
        log "PASS: BusyBox httpd is running"
    else
        log "FAIL: BusyBox httpd is not running"
    fi

    if [ -d /mnt/usb/lighty/cgi-bin ]; then
        log "PASS: CGI directory exists at /mnt/usb/lighty/cgi-bin"
    else
        log "FAIL: CGI directory missing at /mnt/usb/lighty/cgi-bin"
    fi

    if [ -r /mnt/usb/lighty/cgi-bin/speak.pl ]; then
        log "PASS: speak.pl exists at /mnt/usb/lighty/cgi-bin/speak.pl"
    else
        log "FAIL: speak.pl missing at /mnt/usb/lighty/cgi-bin/speak.pl"
    fi

    if [ -r /mnt/usb/lighty/lighttpd.conf ]; then
        log "PASS: lighttpd config exists at /mnt/usb/lighty/lighttpd.conf"
    else
        log "FAIL: lighttpd config missing at /mnt/usb/lighty/lighttpd.conf"
    fi

    copy_diagnostics_to_usb
}

initial_diagnostics
show_splash
restore_zurk_runtime
post_startup_diagnostics
validate_runtime

log "entering persistent foreground redraw loop"
copy_diagnostics_to_usb
while true; do
    write_screen || log "ERROR: redraw failed"
    sleep "$REDRAW_SECONDS"
done