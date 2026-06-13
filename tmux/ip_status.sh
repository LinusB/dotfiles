#!/usr/bin/env bash

MAIN_IP=""
ALL_IPS=""
VPN_IPS=""

# 1. IPs abhängig vom Betriebssystem sammeln
if command -v ip >/dev/null 2>&1; then
  # Linux (Kali, ChromeOS, etc.)
  MAIN_IP=$(ip -4 route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' | head -n 1)
  ALL_IPS=$(ip -4 addr show scope global 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
  VPN_IPS=$(ip -4 addr show 2>/dev/null | grep -E 'tun|wg|tailscale' | awk '/inet / {print $2}' | cut -d/ -f1)
else
  # macOS
  IFACE=$(route -n get default 2>/dev/null | awk '/interface: / {print $2}')
  if [ -n "$IFACE" ]; then
    MAIN_IP=$(ifconfig "$IFACE" 2>/dev/null | awk '/inet / {print $2}')
  fi
  # Alle IPv4 außer Localhost (127.0.0.1)
  ALL_IPS=$(ifconfig 2>/dev/null | awk '/inet / && $2 != "127.0.0.1" {print $2}')
  # VPN spezifische Interfaces (utun, tun, wg)
  VPN_IPS=$(ifconfig 2>/dev/null | awk '/^utun|^tun|^wg/ {active=1} /^[a-z]/ && !/^utun|^tun|^wg/ {active=0} active && /inet / && $2 != "127.0.0.1" {print $2}')
fi

OUTPUT=""

# 2. PRIO 1: Main Traffic IP (Grün)
if [ -n "$MAIN_IP" ]; then
  OUTPUT="#[fg=#a6e3a1,bg=default]󰖟 $MAIN_IP"
fi

# 3. PRIO 2: Weitere lokale IPv4 (Cyan)
for ip in $ALL_IPS; do
  # Überspringe die Main IP (die haben wir schon)
  if [ "$ip" = "$MAIN_IP" ]; then
    continue
  fi

  # Prüfen, ob die IP zum VPN gehört
  IS_VPN=false
  for vip in $VPN_IPS; do
    if [ "$ip" = "$vip" ]; then
      IS_VPN=true
      break
    fi
  done

  # Wenn es eine normale lokale IP ist, anhängen
  if [ "$IS_VPN" = false ]; then
    FORMATTED="#[fg=#89dceb,bg=default]󰩟 $ip"
    if [ -z "$OUTPUT" ]; then
      OUTPUT="$FORMATTED"
    else
      OUTPUT="$OUTPUT #[fg=#45475a]│ $FORMATTED"
    fi
  fi
done

# 4. PRIO 3: VPN IPs (Rot)
for ip in $VPN_IPS; do
  FORMATTED="#[fg=#f38ba8,bg=default]󰖂 $ip"
  if [ -z "$OUTPUT" ]; then
    OUTPUT="$FORMATTED"
  else
    OUTPUT="$OUTPUT #[fg=#45475a]│ $FORMATTED"
  fi
done

echo "$OUTPUT"
