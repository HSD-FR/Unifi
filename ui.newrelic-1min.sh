#!/bin/bash
###############################################
###                                         ###
###     UI Health API                       ###
###     NEWRELIC API for Unifi v1.1         ###
###     2026-04-22   StillTRue(c)           ###
###                                         ###
###############################################
# The goal of this script is to get the health status of the gateway through API
# and send the result through the New Relic API

SCRIPT_DIR="/mnt/data"
LOG_FILE="/mnt/data/log/ui_newrelic.log"

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

JSON=$(curl -k   -H "X-API-KEY: $TOKEN" \
		-H "Accept: application/json" \
		"https://127.0.0.1/proxy/network/api/s/default/stat/health")

# -------- EXTRACTION UNIQUE --------
eval $(echo "$JSON" | jq -r '
  .data as $d |

  def get($s): ($d[] | select(.subsystem==$s));

  {
    # -------- META --------
    #hb_meta_rc: .meta.rc,

    # -------- WLAN --------
    #hb_wlan_status: (get("wlan").status),
    #hb_wlan_num_user: (get("wlan").num_user),
    #hb_wlan_num_guest: (get("wlan").num_guest),
    #hb_wlan_num_iot: (get("wlan").num_iot),
    #hb_wlan_tx_bytes_r: (get("wlan")["tx_bytes-r"]),
    #hb_wlan_rx_bytes_r: (get("wlan")["rx_bytes-r"]),
    #hb_wlan_num_ap: (get("wlan").num_ap),
    #hb_wlan_num_adopted: (get("wlan").num_adopted),
    #hb_wlan_num_disabled: (get("wlan").num_disabled),
    #hb_wlan_num_disconnected: (get("wlan").num_disconnected),
    #hb_wlan_num_pending: (get("wlan").num_pending),

    # -------- WAN --------
    #hb_wan_status: (get("wan").status),
    #hb_wan_num_gw: (get("wan").num_gw),
    #hb_wan_num_adopted: (get("wan").num_adopted),
    #hb_wan_num_disconnected: (get("wan").num_disconnected),
    #hb_wan_num_pending: (get("wan").num_pending),
    #hb_wan_ip: (get("wan").wan_ip),
    #hb_wan_netmask: (get("wan").netmask),
    #hb_wan_nameservers: (get("wan").nameservers | join(",")),
    #hb_wan_num_sta: (get("wan").num_sta),
    #hb_wan_tx_bytes_r: (get("wan")["tx_bytes-r"]),
    #hb_wan_rx_bytes_r: (get("wan")["rx_bytes-r"]),
    #hb_wan_gw_mac: (get("wan").gw_mac),
    #hb_wan_gw_name: (get("wan").gw_name),
    #hb_wan_gw_version: (get("wan").gw_version),
    #hb_wan_isp_name: (get("wan").isp_name),
    #hb_wan_isp_org: (get("wan").isp_organization),
    #hb_wan_asn: (get("wan").asn),

    # gw_system-stats
    hb_cpu: (get("wan")["gw_system-stats"].cpu),
    hb_mem: (get("wan")["gw_system-stats"].mem),
    hb_uptime: (get("wan")["gw_system-stats"].uptime),

    # uptime WAN
    hb_uptime_wan: (get("wan").uptime_stats.WAN.uptime),
    hb_latency_wan: (get("wan").uptime_stats.WAN.latency_average),
    hb_availability_wan: (get("wan").uptime_stats.WAN.availability),

    # uptime WAN2
    hb_uptime_wan2: (get("wan").uptime_stats.WAN2.uptime),
    hb_latency_wan2: (get("wan").uptime_stats.WAN2.latency_average),
    hb_availability_wan2: (get("wan").uptime_stats.WAN2.availability),

    # -------- WWW --------
    #hb_www_status: (get("www").status),
    #hb_www_tx_bytes_r: (get("www")["tx_bytes-r"]),
    #hb_www_rx_bytes_r: (get("www")["rx_bytes-r"]),
    #hb_www_latency: (get("www").latency),
    #hb_www_uptime: (get("www").uptime),
    #hb_www_drops: (get("www").drops),
    #hb_www_xput_up: (get("www").xput_up),
    #hb_www_xput_down: (get("www").xput_down),
    #hb_www_speedtest_status: (get("www").speedtest_status),
    #hb_www_speedtest_lastrun: (get("www").speedtest_lastrun),
    #hb_www_speedtest_ping: (get("www").speedtest_ping),
    #hb_www_gw_mac: (get("www").gw_mac),

    # -------- LAN --------
    #hb_lan_status: (get("lan").status),
    #hb_lan_lan_ip: (get("lan").lan_ip),
    #hb_lan_num_user: (get("lan").num_user),
    #hb_lan_num_guest: (get("lan").num_guest),
    #hb_lan_num_iot: (get("lan").num_iot),
    #hb_lan_tx_bytes_r: (get("lan")["tx_bytes-r"]),
    #hb_lan_rx_bytes_r: (get("lan")["rx_bytes-r"]),
    #hb_lan_num_sw: (get("lan").num_sw),
    #hb_lan_num_adopted: (get("lan").num_adopted),
    #hb_lan_num_disconnected: (get("lan").num_disconnected),
    #hb_lan_num_pending: (get("lan").num_pending),

    # -------- VPN --------
    hb_vpn_status: (get("vpn").status),
    hb_vpn_remote_user_enabled: (get("vpn").remote_user_enabled),
    hb_vpn_remote_user_num_active: (get("vpn").remote_user_num_active),
    hb_vpn_remote_user_num_inactive: (get("vpn").remote_user_num_inactive),
    hb_vpn_remote_user_rx_bytes: (get("vpn").remote_user_rx_bytes),
    hb_vpn_remote_user_tx_bytes: (get("vpn").remote_user_tx_bytes),
    hb_vpn_remote_user_rx_packets: (get("vpn").remote_user_rx_packets),
    hb_vpn_remote_user_tx_packets: (get("vpn").remote_user_tx_packets),
    hb_vpn_site_to_site_enabled: (get("vpn").site_to_site_enabled),
    hb_vpn_site_to_site_num_active: (get("vpn").site_to_site_num_active),
    hb_vpn_site_to_site_num_inactive: (get("vpn").site_to_site_num_inactive),
    hb_vpn_site_to_site_rx_bytes: (get("vpn").site_to_site_rx_bytes),
    hb_vpn_site_to_site_tx_bytes: (get("vpn").site_to_site_tx_bytes),
    hb_vpn_site_to_site_rx_packets: (get("vpn").site_to_site_rx_packets),
    hb_vpn_site_to_site_tx_packets: (get("vpn").site_to_site_tx_packets)
  }
  |
  to_entries
  |
  .[]
  |
  "\(.key)=\(.value|tostring)"
')

# -------- GLOBAL --------

hb_timestamp=$(date +%s)
hb_uuid=$(uuidgen)
hb_service="healthAPI"

# -------- ENVOI --------
response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "https://insights-collector.eu01.nr-data.net/v1/accounts/$NR_account/events" \
-H "X-Insert-Key: $NR_TOKEN" \
-H "Content-Type: application/json" \
-d "[
{
  \"eventType\": \"HSD_event\",
  \"hb_type\": \"ui_health\",
  \"hb_service\": \"$service\",
  \"hb_from\": \"$SITE\",
  \"hb_timestamp\": \"$hb_timestamp\",
  \"hb_uuid\": \"$hb_uuid\",

  \"hb_wlan_status\": \"$hb_wlan_status\",
  \"hb_wan_status\": \"$hb_wan_status\",
  \"hb_www_status\": \"$hb_www_status\",
  \"hb_lan_status\": \"$hb_lan_status\",
  \"hb_vpn_status\": \"$hb_vpn_status\",
  
  \"hb_cpu\": \"$hb_cpu\",
  \"hb_mem\": \"$hb_mem\",
  \"hb_uptime\": \"$hb_uptime\",

  \"hb_uptime_wan\": \"$hb_uptime_wan\",
  \"hb_latency_wan\": \"$hb_latency_wan\",
  \"hb_availability_wan\": \"$hb_availability_wan\",

  \"hb_uptime_wan2\": \"$hb_uptime_wan2\",
  \"hb_latency_wan2\": \"$hb_latency_wan2\",
  \"hb_availability_wan2\": \"$hb_availability_wan2\",
  
  \"hb_vpn_status\": \"$hb_vpn_status\",
  \"hb_vpn_remote_user_enabled\": \"$hb_vpn_remote_user_enabled\",
  \"hb_vpn_remote_user_num_active\": \"$hb_vpn_remote_user_num_active\",
  \"hb_vpn_remote_user_num_inactive\": \"$hb_vpn_remote_user_num_inactive\",
  \"hb_vpn_site_to_site_enabled\": \"$hb_vpn_site_to_site_enabled\",
  \"hb_vpn_site_to_site_num_active\": \"$hb_vpn_site_to_site_num_active\",
  \"hb_vpn_site_to_site_num_inactive\": \"$hb_vpn_site_to_site_num_inactive\",

  \"loglevel\": \"INFO\"
}
]")
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Response: $response" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] End of execution scripts" >> "$LOG_FILE"
