#!/usr/bin/env bash
# @omarchy.schemaVersion 1
# @omarchy.title Network & IP Geolocation
# @omarchy.mode fullOutput
# @omarchy.icon 🌐
# @omarchy.packageName Network

LOCAL_IP=$(ip -4 addr show scope global | awk '/inet / {print $2}' | head -n 1)
GATEWAY=$(ip route | awk '/default/ {print $3}')
DNS_SERVERS=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}' | paste -sd ", " -)

cat << EOM
### 🌐 Network Interfaces & IP Configuration

- **Local IP Address:** \`$LOCAL_IP\`
- **Default Gateway:** \`$GATEWAY\`
- **Active DNS Nameservers:** \`$DNS_SERVERS\`

---
Press **↵** to copy local IP address to clipboard.
EOM
