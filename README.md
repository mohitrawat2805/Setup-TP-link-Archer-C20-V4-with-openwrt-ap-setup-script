# Setup-TP-link-Archer-C20-V4-with-openwrt-ap-setup-script
Scripts to configure you Archer C20 AC750 with Open WRT as Access Point.

I have an spare router which I wanted to use it as Access point to my Main router.
The main router will be assigining the IP, so DHCP is enabled on my main router.
the TP-Link Archer C20 V4 AC750 will work as the Access point.
TP-Link supports 2.5 and 5 GHZ networks. I my setup I am Using 2.5 GHz to connect with Main router and 5 GHz as AP.
you can also use 2.5GHz and 5 GHz to connect with main router and 2.5 GHz as AP. you will not be able to use the 5GHz as a connection to main router and AP due to the limitation of 5 GHz.

I my setup I have connected devices to My Archer C20 Via LAN and I wanted a more faster connection to the devices and 2.5 GHz to internet.
you can download the script and configure you main router SSID and password and you AP SSID and new Password.It will do rest of the setup.

sh setup_openwrt_ap.sh

there are commands for debugging and error if any.
