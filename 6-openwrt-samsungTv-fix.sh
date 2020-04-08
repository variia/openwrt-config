# http://blog.tamas.pogany.info/post/2019/07/15/HBO-Go-DRM-hiba-es-51-lejatszasi-hiba
# https://openwrt.org/docs/guide-user/base-system/dhcp_configuration#classifying_clients_and_assigning_individual_options1

# HBO GO stops working on Samsung TVs where upstream router is using
# custom DNS such as AdBlocker based, privacy focused Cloudfare, etc.

# Some suggests it has something to do with certain DNS services
# blocking HBO DRM servers or incorrect geo based responses.
# Either way, the fix is usually dishing out custom DHCP option to
# your Samsung Tele and default its DNS to Google's public servers.

HOSTNAME="samsungTV"
TAG="googleDNS"
MAC=""
IPADDR=""
DNS1="8.8.4.4"
DNS2="8.8.8.8"

uci batch <<EOF
  set dhcp.${HOSTNAME}="host"
  set dhcp.${HOSTNAME}.name="${HOSTNAME}"
  set dhcp.${HOSTNAME}.mac="${MAC}"
  set dhcp.${HOSTNAME}.ip="${IPADDR}"
  set dhcp.${HOSTNAME}.tag="${TAG}"
  set dhcp.${TAG}="tag"
  set dhcp.${TAG}.dhcp_option="6,${DNS1},${DNS2}"
EOF

uci commit && cd /etc/init.d && \
./dnsmasq restart
