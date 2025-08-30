#!/bin/bash
###############################################
###                                         ###
###     DDNS CloudFlare for Unifi v1.1      ###
###     2025-08-23   StillTRue(c)           ###
###                                         ###
###############################################

LOG_FILE="/mnt/data/log/DDNS_CloudFlare.log"

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
# Function Get current IPs
# -----------------------------

get_ip() {
    local TYPE=$1
    if [ "$TYPE" = "A" ]; then
        curl -4 --silent --interface "$INTERFACE" https://api64.ipify.org
    elif [ "$TYPE" = "AAAA" ]; then
        curl -6 --silent --interface "$INTERFACE" https://api64.ipify.org
    else
        echo ""
    fi
}

# -----------------------------
# Function Update or create
# -----------------------------

update_record() {
    HOST="$1"
    TYPE="$2"
    NEW_IP="$3"
    DATE_NOW=$(date +"%Y-%m-%d %H:%M:%S")

    if [ -z "$NEW_IP" ]; then
        echo "$DATE_NOW No IP for $HOST ($TYPE)" >> "$LOG_FILE"
        return 1
    fi
# -----------------------------
# Get Record ID & IP from Cloudflare
# -----------------------------

    RECORD=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=$TYPE&name=$HOST" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json")

	SUCCESS=$(echo "$RECORD" | jq -r '.success')

	if [ "$SUCCESS" != "true" ]; then
    	ERRORS=$(echo "$RECORD" | jq -r '.errors[]?.message')
    	echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Cloudflare API request failed: $ERRORS" >> "$LOG_FILE"
    	exit 1
	fi
    # ID record (get 1st if more than 1)
	RECORD_ID=$(echo "$RECORD" | jq -r '.result[0].id // empty')
	RECORD_IP=$(echo "$RECORD" | jq -r '.result[0].content // empty')

# -----------------------------
# If record doesn't exist, creation
# -----------------------------

	if [ -z "$RECORD_ID" ]; then
		echo "$DATE_NOW Record missing, creating $TYPE $HOST -> $NEW_IP" >> "$LOG_FILE"
        curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
            -H "Authorization: Bearer $API_TOKEN" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"$TYPE\",\"name\":\"$HOST\",\"content\":\"$NEW_IP\",\"ttl\":$TTL,\"proxied\":$PROXIED,\"comment\":\"Created by Unifi on $DATE_NOW\"}" >/dev/null
        
        echo "$DATE_NOW Record created : $HOST -> $NEW_IP" >> "$LOG_FILE"
        return 0
    fi

# -----------------------------
    # Nothing to do
# -----------------------------
    
    if [ "$RECORD_IP" = "$NEW_IP" ]; then
    	echo "$DATE_NOW No IP change for $HOST ($TYPE)." >> "$LOG_FILE"
        return 0
    fi

# -----------------------------
    # Update record
# -----------------------------

    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"$TYPE\",\"name\":\"$HOST\",\"content\":\"$NEW_IP\",\"ttl\":$TTL,\"proxied\":$PROXIED,\"comment\":\"Updated by Unifi on $DATE_NOW\"}" >/dev/null

    echo "$DATE_NOW Update done : $CURRENT_IP -> $NEW_IP ($HOST $TYPE)" >> "$LOG_FILE"
    return 0
}

# -----------------------------
# Call function
# -----------------------------
for ENTRY in "${DNS_RECORDS[@]}"; do
    HOST=$(echo $ENTRY | awk '{print $1}')
    TYPE=$(echo $ENTRY | awk '{print $2}')
    NEW_IP=$(get_ip "$TYPE")
    update_record "$HOST" "$TYPE" "$NEW_IP"
done
