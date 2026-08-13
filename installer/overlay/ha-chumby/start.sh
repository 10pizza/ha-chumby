#!/bin/sh
# Minimal persistent HA-Chumby boot confirmation screen.

APP_DIR="$(dirname "$0")"
IMAGE="$APP_DIR/boot-screen.rgb565"
LOG="/tmp/ha-chumby.log"
FRAMEBUFFER=""
REDRAW_SECONDS=2

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') start.sh: $*" >> "$LOG"
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
}

write_screen() {
    if [ -n "$FRAMEBUFFER" ] && [ -r "$IMAGE" ]; then
        cat "$IMAGE" > "$FRAMEBUFFER"
        return $?
    fi
    return 1
}

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
while true; do
    write_screen || log "ERROR: redraw failed"
    sleep "$REDRAW_SECONDS"
done
