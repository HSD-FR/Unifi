#!/bin/bash
###############################################
###                                         ###
###     Crontab - exec 1min & 5min v1.1     ###
###     2026-03-23   StillTRue(c)           ###
###                                         ###
###############################################

# Script runner to execute all *5min.sh and all *1min.sh scripts
# Put this in cron every 1 minute

SCRIPT_DIR="/mnt/data"
LOG_FILE="/mnt/data/log/crontab.log"

# Create log file if not exists
touch "$LOG_FILE"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running scheduled scripts" >> "$LOG_FILE"

# Function to run scripts matching a pattern
run_scripts() {
    local pattern=$1
    for script in "$SCRIPT_DIR"/*"$pattern"; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Executing $script" >> "$LOG_FILE"
                "$script" >> "$LOG_FILE" 2>&1
            else
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Skipping $script (not executable)" >> "$LOG_FILE"
            fi
        fi
    done
}

MINUTE=$(date +%M)

# Run 1min scripts
run_scripts "-1min.sh"

# Run 5min scripts only every 5 minutes
if ((10#$MINUTE % 5 == 0)); then
    run_scripts "-5min.sh"
fi
