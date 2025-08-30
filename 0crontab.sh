#!/bin/bash
###############################################
###                                         ###
###     Crontab - exec every 5min v1.O      ###
###     2025-08-30   StillTRue(c)           ###
###                                         ###
###############################################

# Script runner to execute all *5min.sh scripts
# Put this in cron every 5 minutes

SCRIPT_DIR="/mnt/data"
LOG_FILE="/mnt/data/log/crontab.log"

# Create log file if not exists
touch "$LOG_FILE"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running all *5min.sh scripts" >> "$LOG_FILE"

for script in "$SCRIPT_DIR"/*-5min.sh; do
    if [ -x "$script" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Executing $script" >> "$LOG_FILE"
        "$script" >> "$LOG_FILE" 2>&1
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Skipping $script (not executable)" >> "$LOG_FILE"
    fi
done
