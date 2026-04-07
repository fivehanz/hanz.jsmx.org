#!/bin/sh
set -eu

APP_DIR="/usr/local/www/wagtail"
LOCK="/tmp/wagtail-deploy.lock"

cd "$APP_DIR"

# ---- lock ----
if [ -f "$LOCK" ]; then
    echo "== deploy already running =="
    exit 0
fi

trap 'rm -f "$LOCK"' EXIT
touch "$LOCK"

echo "== deploy start =="

# ---- check for updates ----
git fetch origin

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "== no changes =="
    exit 0
fi

echo "== updating =="
git pull --ff-only

# ---- app updates ----
just setup-uv
just setup-staticfiles
just migrate

# ---- restart ----
just prod-start

echo "== deploy done =="