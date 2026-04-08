#!/bin/sh
set -eu

# ---- CONFIG ---- #

APP_DIR="/usr/local/www/wagtail"
ENV_FILE="/usr/local/etc/wagtail/env"

SOCK="/var/run/wagtail/wagtail.sock"
UMASK="007"

# ---- PREP ---- #

# ensure predictable permissions for socket (660)
umask "$UMASK"

# load environment (must exist)
if [ ! -f "$ENV_FILE" ]; then
    echo "env file missing: $ENV_FILE" >&2
    exit 1
fi

# shellcheck disable=SC1090
. "$ENV_FILE"

# ensure app dir exists
if [ ! -d "$APP_DIR" ]; then
    echo "app dir missing: $APP_DIR" >&2
    exit 1
fi

cd "$APP_DIR"

# ---- SOCKET SAFETY ---- #

# remove stale socket if present
if [ -S "$SOCK" ]; then
    rm -f "$SOCK"
fi

# ---- EXEC ---- #

# ensure mise environment is used from repo
python3.11 -m granian \
    --interface asginl \
    --uds "$SOCK" \
    --uds-permissions 660 \
    --workers 1 \
    --workers-max-rss 120 \
    --log-level info \
    config.asgi:application
