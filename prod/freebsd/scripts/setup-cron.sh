#!/bin/sh
set -eu

CRON_LINE='* * * * * date "+\n==== %Y-%m-%d %H:%M:%S ====" >> /var/log/wagtail-deploy.log 2>&1; /usr/local/www/wagtail/deploy.sh >> /var/log/wagtail-deploy.log 2>&1'

LOG_FILE="/var/log/wagtail-deploy.log"
TMP_CRON="/tmp/wagtail-cron.tmp"

echo "== setting up deploy cron =="

# ---- log file ----
touch "$LOG_FILE"
chown root:wheel "$LOG_FILE"
chmod 644 "$LOG_FILE"

# ---- build cron safely ----
crontab -l 2>/dev/null | grep -v 'deploy.sh' > "$TMP_CRON" || true
echo "$CRON_LINE" >> "$TMP_CRON"

# ---- install ----
crontab "$TMP_CRON"
rm "$TMP_CRON"

echo "== cron installed =="