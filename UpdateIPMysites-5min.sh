#!/bin/bash
###############################################
###                                         ###
###     Update FW Group for Unifi v1.O      ###
###     2025-08-30   StillTRue(c)           ###
###                                         ###
###############################################

LOG_FILE="/mnt/data/log/Update_IPMySites.log"

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

# --- Config ---
SITE="default"
UNIFI_URL="https://127.0.0.1"
DNS_RESOLVER="1.1.1.1"
STATEFILE="/tmp/unifi_dnslist.state"

# variable from z_variables.conf
#HOSTS_FWGIPv4=
#FWGROUP_ID=
#TOKEN=

# --- Résolution DNS via Cloudflare ---
IPS=()
for H in "${HOSTS_FWGIPv4[@]}"; do
  IP=$(dig +short "$H" @"$DNS_RESOLVER" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | tail -n1)
  [ -n "$IP" ] && IPS+=("$IP")
done
[ ${#IPS[@]} -eq 0 ] && echo "$(date +"%Y-%m-%d %H:%M:%S") ❌ Aucune IP résolue" && exit 1 >> "$LOG_FILE"

NEW=$(printf "%s," "${IPS[@]}" | sed 's/,$//')
OLD=$( [ -f "$STATEFILE" ] && cat "$STATEFILE" || echo "" )

# --- Mise à jour si changement ---
if [ "$NEW" != "$OLD" ]; then
  curl -sk -X PUT \
    -H "Content-Type: application/json" \
    -H "X-API-KEY: $TOKEN" \
    "$UNIFI_URL/proxy/network/api/s/$SITE/rest/firewallgroup/$FWGROUP_ID" \
    --data "{\"group_members\":[$(printf '"%s",' "${IPS[@]}" | sed 's/,$//')]}"
  echo "$NEW" > "$STATEFILE"
  echo "$(date +"%Y-%m-%d %H:%M:%S") 🔄 Mise à jour : $NEW" >> "$LOG_FILE"
else
  echo "$(date +"%Y-%m-%d %H:%M:%S") ✅ Pas de changement ($NEW)" >> "$LOG_FILE"
fi
