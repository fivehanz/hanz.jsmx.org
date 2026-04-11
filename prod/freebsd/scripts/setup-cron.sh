#!/bin/sh
set -eu

CRON_LINE='* * * * * date "+\n==== %Y-%m-%d %H:%M:%S ====" >> /var/log/wagtail-deploy.log 2>&1; /usr/local/www/wagtail/deploy.sh >> /var/log/wagtail-deploy.log 2>&1'

LOG_FILE="/var/log/wagtail-deploy.log"

echo "== setting up deploy cron =="

# ---- ensure log file exists ----
touch "$LOG_FILE"
chown root:wheel "$LOG_FILE"
chmod 644 "$LOG_FILE"

# ---- install cron safely (idempotent) ----
(crontab -l 2>/dev/null | grep -v 'deploy.sh'; echo "$CRON_LINE") | crontab -

echo "== cron installed =="