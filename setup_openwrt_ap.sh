#!/bin/sh
# Archer C20 Repeater Setup Script with Debug Menu
# Tested on OpenWrt 22.x style UCI config
# Run: sh setup_repeater.sh

MAIN_SSID="YourMainRouterSSID"
MAIN_PASS="YourMainRouterPassword"
AP_SSID="MyRepeater-5G"
AP_PASS="StrongPassword123"

echo "=== STEP 1: Connect 2.4GHz radio to Main Router ==="
uci set wireless.radio0.disabled=0
uci set wireless.sta=wifi-iface
uci set wireless.sta.device='radio0'
uci set wireless.sta.mode='sta'
uci set wireless.sta.network='wwan'
uci set wireless.sta.ssid="$MAIN_SSID"
uci set wireless.sta.encryption='psk2'
uci set wireless.sta.key="$MAIN_PASS"

echo "=== STEP 2: Setup 5GHz AP ==="
uci set wireless.radio1.disabled=0
uci set wireless.repeater=wifi-iface
uci set wireless.repeater.device='radio1'
uci set wireless.repeater.mode='ap'
uci set wireless.repeater.ssid="$AP_SSID"
uci set wireless.repeater.encryption='psk2'
uci set wireless.repeater.key="$AP_PASS"
uci set wireless.repeater.network='lan'

echo "=== STEP 3: Setup network & relayd ==="
opkg update
opkg install relayd

uci set network.wwan=interface
uci set network.wwan.proto='dhcp'

uci set network.stabridge=interface
uci set network.stabridge.proto='relay'
uci add_list network.stabridge.network='lan'
uci add_list network.stabridge.network='wwan'

uci set dhcp.lan.ignore='1'  # Disable DHCP on repeater
uci commit

echo "=== STEP 4: Reload config ==="
wifi reload
/etc/init.d/network restart
/etc/init.d/dnsmasq restart
/etc/init.d/relayd restart

echo "=== STEP 5: Save configuration to survive reboot ==="
uci commit
sync

cat <<'EOF' >/usr/bin/repeater-debug
#!/bin/sh
echo "=== Debug: Internet Test ==="
ping -c 3 8.8.8.8 || echo "❌ No Internet"
wget -qO- http://ifconfig.me || echo "❌ No Public IP"

echo "=== Debug: Wireless Links ==="
iw dev
iwinfo wlan0 link
iwinfo wlan1 info

echo "=== Debug: Routing Table ==="
ip route show

echo "=== Debug: NAT / Firewall Tables ==="
iptables -t nat -L -v --line-numbers

echo "=== Debug: Traceroute to Google ==="
traceroute 8.8.8.8 || echo "Traceroute not installed (opkg install iputils-traceroute)"
EOF
chmod +x /usr/bin/repeater-debug

uci export > /root/openwrt_config_backup.txt

echo "=== SETUP COMPLETE ==="
echo "Run 'repeater-debug' anytime to check status"
