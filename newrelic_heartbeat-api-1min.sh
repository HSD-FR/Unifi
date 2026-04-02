#!/bin/bash
###############################################
###                                         ###
###     NEWRELIC API for Unifi v1.1         ###
###     2026-04-22   StillTRue(c)           ###
###                                         ###
###############################################
# The goal of this script is to test all internet interface status, and the VPNS2S
# and send the result through the New Relic API

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
# Function to test internet access
# -----------------------------

check_and_syslog() {
	
	local interface="$1"
    local target="$2"
    local service="$3"
    UUID=$(uuidgen)

    if [ -n "$interface" ]; then
        ping_cmd="ping -I ${interface}"
    else
        ping_cmd="ping"
    fi

    if $ping_cmd -c 3 -W 5 "$target" > /dev/null 2>&1 ; then
        status="ok"
    else
        status="ko"
    fi
    
    curl -X POST "https://insights-collector.eu01.nr-data.net/v1/accounts/$NR_account/events" \
 			-H "X-Insert-Key: $NR_TOKEN" \
 			-H "Content-Type: application/json" \
 			-d "[{\"eventType\": \"HSD_event\", \
 				\"hb_type\": \"heartbeat\", \
 				\"hb_service\": \"$service\", \
 				\"hb_from\": \"$SITE\", \
 				\"hb_status\": \"$status\", \
 				\"hb_timestamp\": \"$(date +%s)\", \
 				\"hb_uuid\": \"$UUID\", \
 				\"loglevel\": \"INFO\" }]" 
}

# -----------------------------
# Function to test VPN tunnel
# -----------------------------

check_vpn_and_syslog() {
  	
  	local service="$1"
  	UUID=$(uuidgen)
    
  	if /usr/sbin/ipsec status | grep -q "ESTABLISHED"; then
   		status="ok"
 	else
    	status="ko"
  	fi
        
	curl -X POST "https://insights-collector.eu01.nr-data.net/v1/accounts/$NR_account/events" \
 		-H "X-Insert-Key: $NR_TOKEN" \
 		-H "Content-Type: application/json" \
 		-d "[{\"eventType\": \"HSD_event\", \
 			\"hb_type\": \"heartbeat\", \
 			\"hb_service\": \"$service\", \
 			\"hb_from\": \"$SITE\", \
			\"hb_status\": \"$status\", \
 			\"hb_timestamp\": \"$(date +%s)\", \
 			\"hb_uuid\": \"$UUID\", \
 			\"loglevel\": \"INFO\" }]" 
}

# ---- Vérifications ----

# Test FTTH (eth4 → internet)
check_and_syslog "$INTERFACE_1" $PING_IP_1 "$SERVICE_1"

# Test LTE (eth3 → internet)
check_and_syslog "$INTERFACE_2" $PING_IP_2 "$SERVICE_2"

# Test VPN LAN (pas d'interface à forcer)
check_vpn_and_syslog "$SERVICE_3"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] End of execution scripts" >> "$LOG_FILE"

