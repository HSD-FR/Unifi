#!/bin/bash
###############################################
###                                         ###
###     NEWRELIC for Unifi v1.0             ###
###     2026-03-22   StillTRue(c)           ###
###                                         ###
###############################################

SCRIPT_DIR="/mnt/data"
LOG_FILE="/mnt/data/log/newrelic.log"

# Create log file if not exists
touch "$LOG_FILE"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running scheduled scripts" >> "$LOG_FILE"

# -----------------------------
# Get local variables
# -----------------------------

CONFIG_FILE="/mnt/data/z_variables.conf"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "$(date +"%Y-%m-%d %H:%M:%S") Config file not found: $CONFIG_FILE" >> "$LOG_FILE"
    exit 1
fi

# -----------------------------
# Get local variables
# -----------------------------

check_and_syslog() {
    local interface="$1"
    local target="$2"
    local service="$3"

    if [ -n "$interface" ]; then
        ping_cmd="ping -I ${interface}"
    else
        ping_cmd="ping"
    fi

    if $ping_cmd -c 2 "$target" > /dev/null 2>&1 ; then
        UUID=$(uuidgen)
        logger -n $SYSLOG_IP -P 514 -d -t heartbeat "hb_type=heartbeat,hb_service=$service,hb_from=$SITE,hb_status=ok,hb_timestamp=$(date +%s),hb_uuid=$UUID"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ping $target through $SITE-$service UUID=$UUID" >> "$LOG_FILE"
    fi
}

check_vpn_and_syslog() {
	local service2="$1"
    UUID=$(uuidgen)	
	if /usr/sbin/ipsec status | grep -q "ESTABLISHED"; then
    	logger -n $SYSLOG_IP -P 514 -d -t heartbeat "hb_type=heartbeat,hb_service=$service2,hb_from=$SITE,hb_status=ok,hb_timestamp=$(date +%s),hb_uuid=$UUID"
    	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $service2 UP through $SITE-$service2 UUID=$UUID" >> "$LOG_FILE"
	fi
	
}
# ---- Vérifications ----

# Test FTTH (eth4 → internet)
check_and_syslog "eth4" $PING_IP "WAN1"

# Test LTE (eth3 → internet)
check_and_syslog "eth3" $PING_IP "WAN2"

# Test VPN LAN (pas d'interface à forcer)
check_vpn_and_syslog "VPNS2S"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] End of execution scripts" >> "$LOG_FILE"
