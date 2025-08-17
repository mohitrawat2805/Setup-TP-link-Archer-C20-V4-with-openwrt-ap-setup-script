#!/bin/sh
# Archer OpenWrt Repeater Setup Script (Interactive)
# Works as WiFi Repeater/Bridge with optional Debug Tools

set -e

echo "=== OpenWrt Repeater Setup ==="

# Ask for inputs interactively
read -p "Enter your MAIN router SSID: " MAIN_SSID
read -sp "Enter your MAIN router WiFi password: " MAIN_PASS
echo ""
read -p "Enter AP SSID (what this repeater should broadcast): " AP_SSID
read -sp "Enter AP WiFi password: " AP_PASS
echo ""

echo "Inputs received:"
echo "  Main SSID: $MAIN_SSID"
echo "  Repeater SSID: $AP_SSID"
echo ""

echo "Proceeding with setup..."

# Backup config
cp /etc/config/wireless /etc/config/wireless.bak.$(date +%s)
cp /etc/config/network /etc/config/network.bak.$(date +%s)

# Configure STA (client mode to connect to main router)
uci set wireless.sta=wifi-iface
uci set wireless.sta.device='radio0'
uci set wireless.sta.mode='sta'
uci set wireless.sta.network='wwan'
uci set wireless.sta.ssid="$MAIN_SSID"
uci set wireless.sta.encryption='psk2'
uci set wireless.sta.key="$MAIN_PASS"

# Configure AP (broadcast WiFi for clients)
uci set wireless.ap=wifi-iface
uci set wireless.ap.device='radio1'
uci set wireless.ap.mode='ap'
uci set wireless.ap.network='lan'
uci set wireless.ap.ssid="$AP_SSID"
uci set wireless.ap.encryption='psk2'
uci set wireless.ap.key="$AP_PASS"

uci commit wireless
wifi reload

# Configure networks
uci set network.wwan=interface
uci set network.wwan.proto='dhcp'

uci commit network
/etc/init.d/network restart

# Firewall/NAT bypass (so it works as transparent AP)
uci set firewall.@zone[1].forward='ACCEPT'
uci set firewall.@zone[1].masq='0'
uci set firewall.@zone[1].mtu_fix='0'
uci commit firewall
/etc/init.d/firewall restart

echo "=== Setup completed successfully! ==="
echo "Repeater SSID: $AP_SSID"
echo "Connected to main SSID: $MAIN_SSID"
echo ""

# Add debug menu
while true; do
    echo "=== Debug Menu ==="
    echo "1) Check WiFi Status"
    echo "2) Show Routing Table"
    echo "3) Show NAT Table"
    echo "4) Traceroute to 8.8.8.8"
    echo "5) Exit"
    read -p "Choose option: " opt
    case $opt in
        1) iw dev wlan0 link; iw dev wlan1 link ;;
        2) ip route ;;
        3) iptables -t nat -L -n -v ;;
        4) traceroute 8.8.8.8 ;;
        5) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done
