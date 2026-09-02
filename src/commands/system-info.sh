#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title System Hardware & Resource Monitor
# @raycast.mode fullOutput
# @raycast.icon 📊
# @raycast.packageName System

CPU_LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | xargs)
MEM_INFO=$(free -h | awk '/Mem:/ {print $3 "/" $2 " (" $7 " available)"}')
UPTIME_VAL=$(uptime -p)
KERNEL_VAL=$(uname -r)
BATT_VAL=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo "AC Connected")

cat << EOM
### 🖥️ Machine & System Status

- **CPU Load (1m, 5m, 15m):** \`$CPU_LOAD\`
- **Memory Usage:** \`$MEM_INFO\`
- **System Uptime:** \`$UPTIME_VAL\`
- **Linux Kernel:** \`$KERNEL_VAL\`
- **Battery Status:** \`$BATT_VAL%\`
- **Compositor:** \`Hyprland 0.56.2 (Wayland)\`

---
*Generated live by Omnicast Script Engine*
EOM
