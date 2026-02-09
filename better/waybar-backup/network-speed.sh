#!/usr/bin/env bash
# Print JSON for waybar module: shows icon+speeds in text and detailed speeds in tooltip
set -euo pipefail

CACHE_DIR=/tmp/waybar-net
mkdir -p "$CACHE_DIR"

get_iface(){
  ip route get 1.1.1.1 2>/dev/null | awk '/dev/ {for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -n1
}

human(){
  local b=$1
  if [ "$b" -ge 1000000000 ]; then
    printf "%.1fG/s" "$(awk "BEGIN {print $b/1000000000}")"
  elif [ "$b" -ge 1000000 ]; then
    printf "%.1fM/s" "$(awk "BEGIN {print $b/1000000}")"
  elif [ "$b" -ge 1000 ]; then
    printf "%.1fK/s" "$(awk "BEGIN {print $b/1000}")"
  else
    printf "%db/s" "$b"
  fi
}

iface=$(get_iface || true)
if [ -z "$iface" ]; then
  echo '{"text":"󰤮","tooltip":"Disconnected"}'
  exit 0
fi

rx_file="/sys/class/net/$iface/statistics/rx_bytes"
tx_file="/sys/class/net/$iface/statistics/tx_bytes"
if [ ! -r "$rx_file" ] || [ ! -r "$tx_file" ]; then
  echo '{"text":"󰤮","tooltip":"No stats"}'
  exit 0
fi

now=$(date +%s)
rx=$(cat "$rx_file")
tx=$(cat "$tx_file")
cache="$CACHE_DIR/$iface"
if [ -f "$cache" ]; then
  read -r prx ptx ptime < "$cache"
else
  prx=0
  ptx=0
  ptime=$now
fi

dt=$(( now - ptime ))
if [ $dt -le 0 ]; then dt=1; fi

drx=$(( rx - prx ))
dtx=$(( tx - ptx ))
ups=$(( dtx / dt ))
dns=$(( drx / dt ))

echo "$rx $tx $now" > "$cache"

up_h=$(human $ups)
down_h=$(human $dns)

# detect wireless signal strength (if available) and map to icon
signal_pct=""
ssid=""
if command -v nmcli >/dev/null 2>&1; then
  # prefer nmcli to get SSID and SIGNAL for the active connection
  # output format: ACTIVE:SSID:SIGNAL
  read -r active ss signal <<< "$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | awk -F: '$1=="yes" {print $1, $2, $3; exit}')" || true
  if [ -n "$signal" ]; then
    signal_pct="$signal"
  fi
  if [ -n "$ss" ]; then
    ssid="$ss"
  fi
fi

# fallback: try iw to obtain signal level in dBm and convert to pct
if [ -z "$signal_pct" ] && command -v iw >/dev/null 2>&1; then
  sigdb=$(iw dev "$iface" link 2>/dev/null | awk '/signal:/ {print $2}') || true
  if [ -n "$sigdb" ]; then
    # approximate conversion from dBm (-100..0) to 0..100
    signal_pct=$(( (sigdb + 100) * 2 ))
    if [ $signal_pct -lt 0 ]; then signal_pct=0; fi
    if [ $signal_pct -gt 100 ]; then signal_pct=100; fi
  fi
fi

# choose icon based on percentage
icons=("󰤯" "󰤟" "󰤢" "󰤥" "󰤨")
icon="󰤯"
if [ -n "$signal_pct" ]; then
  idx=$(( (signal_pct * (${#icons[@]} - 1)) / 100 ))
  icon=${icons[$idx]}
fi

text="$icon"
tooltip="Interface: $iface\nSSID: ${ssid:-N/A}\nUpload: $up_h\nDownload: $down_h"

printf '{"text":"%s","tooltip":"%s"}' "$text" "$tooltip"
