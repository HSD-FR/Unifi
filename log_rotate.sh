#!/bin/bash
###############################################
# Monthly log rotation for /mnt/data/log
# Keeps only the current and previous month
###############################################

LOG_DIR="/mnt/data/log"
DATE_NOW=$(date +"%Y-%m-%d_%H-%M-%S")

# -----------------------------
# Rotate only active logs (without _YYYY-MM-DD suffix)
# -----------------------------
for FILE in "$LOG_DIR"/*.log; do
    [ -e "$FILE" ] || continue
        BASENAME=$(basename "$FILE" .log)
        mv "$FILE" "$LOG_DIR/${DATE_NOW}_${BASENAME}.arch"
done

# -----------------------------
# Keep only last 2 months
# -----------------------------
# Remove files older than 2 months
find "$LOG_DIR" -type f -name "*.log" -mtime +60 -exec rm -f {} \;

echo "$(date +"%Y-%m-%d %H:%M:%S") Log rotation done." >> "$LOG_DIR/log_rotation.log"
