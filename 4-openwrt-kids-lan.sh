# https://openwrt.org/docs/guide-user/network/wifi/guestwifi/configuration
# https://openwrt.org/docs/guide-user/network/wifi/guestwifi/guest-wlan

# free OpenDNS service to block adult sites only (no config required, just set and go)
ODNS_FAMILYSHIELD1="208.67.222.123"
ODNS_FAMILYSHIELD2="208.67.220.123"

# free OpenDNS service to control blocked sites (opendns account, configuration required)
ODNS_HOMEFREE1="208.67.222.222"
ODNS_HOMEFREE2="208.67.220.220"

# default DNS
DNS1="${ODNS_HOMEFREE1}"
DNS2="${ODNS_HOMEFREE2}"

# kids zone
NETWORKID=kid
FIREWALLZONE=${NETWORKID}
SUBNET=
MASK=
SSID=
WIFISECRET=

# enabled services
PORTS="25 80 123 443 465 587 993 995"

uci batch <<EOF
  delete network.${NETWORKID}

  set network.${NETWORKID}=interface
  set network.${NETWORKID}.ifname=${NETWORKID}
  set network.${NETWORKID}.type='bridge'
  set network.${NETWORKID}.proto=static
  set network.${NETWORKID}.ipaddr=${SUBNET}
  set network.${NETWORKID}.netmask=${MASK}
  set network.${NETWORKID}.ip6assign='60'

  delete dhcp.${NETWORKID}

  set dhcp.${NETWORKID}=dhcp
  set dhcp.${NETWORKID}.interface=${NETWORKID}
  set dhcp.${NETWORKID}.start=100
  set dhcp.${NETWORKID}.limit=150
  set dhcp.${NETWORKID}.leasetime=12h
  set dhcp.${NETWORKID}.dhcpv6=server
  set dhcp.${NETWORKID}.ra=server
  add_list dhcp.${NETWORKID}.dhcp_option="6,${DNS1}"
  add_list dhcp.${NETWORKID}.dhcp_option="6,${DNS2}"

  delete firewall.${FIREWALLZONE}

  set firewall.${FIREWALLZONE}=zone
  set firewall.${FIREWALLZONE}.name=${FIREWALLZONE}
  set firewall.${FIREWALLZONE}.network=${NETWORKID}
  set firewall.${FIREWALLZONE}.forward=REJECT
  set firewall.${FIREWALLZONE}.output=ACCEPT
  set firewall.${FIREWALLZONE}.input=REJECT

  delete firewall.${FIREWALLZONE}_fwd

  set firewall.${FIREWALLZONE}_fwd=forwarding
  set firewall.${FIREWALLZONE}_fwd.src=${NETWORKID}
  set firewall.${FIREWALLZONE}_fwd.dest=wan

  delete firewall.${FIREWALLZONE}_pa_fwd

  set firewall.${FIREWALLZONE}_pa_fwd=rule
  set firewall.${FIREWALLZONE}_pa_fwd.name=Reject-${NETWORKID}-RFC1918A-Fwd
  set firewall.${FIREWALLZONE}_pa_fwd.proto='all'
  set firewall.${FIREWALLZONE}_pa_fwd.src=${NETWORKID}
  set firewall.${FIREWALLZONE}_pa_fwd.dest='wan'
  set firewall.${FIREWALLZONE}_pa_fwd.dest_ip='10.0.0.0/8'
  set firewall.${FIREWALLZONE}_pa_fwd.target=REJECT

  delete firewall.${FIREWALLZONE}_pb_fwd

  set firewall.${FIREWALLZONE}_pb_fwd=rule
  set firewall.${FIREWALLZONE}_pb_fwd.name=Reject-${NETWORKID}-RFC1918B-Fwd
  set firewall.${FIREWALLZONE}_pb_fwd.proto='all'
  set firewall.${FIREWALLZONE}_pb_fwd.src=${NETWORKID}
  set firewall.${FIREWALLZONE}_pb_fwd.dest='wan'
  set firewall.${FIREWALLZONE}_pb_fwd.dest_ip='172.16.0.0/12'
  set firewall.${FIREWALLZONE}_pb_fwd.target=REJECT

  delete firewall.${FIREWALLZONE}_pc_fwd

  set firewall.${FIREWALLZONE}_pc_fwd=rule
  set firewall.${FIREWALLZONE}_pc_fwd.name=Reject-${NETWORKID}-RFC1918C-Fwd
  set firewall.${FIREWALLZONE}_pc_fwd.proto='all'
  set firewall.${FIREWALLZONE}_pc_fwd.src=${NETWORKID}
  set firewall.${FIREWALLZONE}_pc_fwd.dest='wan'
  set firewall.${FIREWALLZONE}_pc_fwd.dest_ip='192.168.0.0/16'
  set firewall.${FIREWALLZONE}_pc_fwd.target=REJECT

  delete firewall.${FIREWALLZONE}_dhcp

  set firewall.${FIREWALLZONE}_dhcp=rule
  set firewall.${FIREWALLZONE}_dhcp.name=Allow-${NETWORKID}-DHCP
  set firewall.${FIREWALLZONE}_dhcp.proto=udp
  set firewall.${FIREWALLZONE}_dhcp.src=${NETWORKID}
  set firewall.${FIREWALLZONE}_dhcp.dest_port=67-68
  set firewall.${FIREWALLZONE}_dhcp.target=ACCEPT

  delete firewall.${FIREWALLZONE}_dns1

  set firewall.${FIREWALLZONE}_dns1=rule
  set firewall.${FIREWALLZONE}_dns1.name=Allow-${NETWORKID}-DNS-1
  set firewall.${FIREWALLZONE}_dns1.proto='tcpudp'
  set firewall.${FIREWALLZONE}_dns1.src=${NETWORKID}
  set firewall.${FIREWALLZONE}_dns1.dest=wan
  set firewall.${FIREWALLZONE}_dns1.dest_ip=${DNS1}
  set firewall.${FIREWALLZONE}_dns1.dest_port=53
  set firewall.${FIREWALLZONE}_dns1.target=ACCEPT

  delete firewall.${FIREWALLZONE}_dns2

  set firewall.${FIREWALLZONE}_dns2=rule
  set firewall.${FIREWALLZONE}_dns2.name=Allow-${NETWORKID}-DNS-2
  set firewall.${FIREWALLZONE}_dns2.proto='tcpudp'
  set firewall.${FIREWALLZONE}_dns2.src=${NETWORKID}
  set firewall.${FIREWALLZONE}_dns2.dest=wan
  set firewall.${FIREWALLZONE}_dns2.dest_ip=${DNS2}
  set firewall.${FIREWALLZONE}_dns2.dest_port=53
  set firewall.${FIREWALLZONE}_dns2.target=ACCEPT

  delete firewall.${FIREWALLZONE}_fwd_out

  set firewall.${FIREWALLZONE}_fwd_out=rule
  set firewall.${FIREWALLZONE}_fwd_out.name=Allow-${NETWORKID}-Traffic
  set firewall.${FIREWALLZONE}_fwd_out.proto='tcpudp'
  set firewall.${FIREWALLZONE}_fwd_out.src=${NETWORKID}
  set firewall.${FIREWALLZONE}_fwd_out.dest=wan
  set firewall.${FIREWALLZONE}_fwd_out.dest_port="${PORTS}"
  set firewall.${FIREWALLZONE}_fwd_out.target=ACCEPT

  delete firewall.${FIREWALLZONE}_in_any

  set firewall.${FIREWALLZONE}_in_any=rule
  set firewall.${FIREWALLZONE}_in_any.name=Reject-${NETWORKID}-Unmatched-Input
  set firewall.${FIREWALLZONE}_in_any.proto='all'
  set firewall.${FIREWALLZONE}_in_any.src=${NETWORKID}
  set firewall.${FIREWALLZONE}_in_any.target=REJECT

  delete firewall.${FIREWALLZONE}_fwd_any

  set firewall.${FIREWALLZONE}_fwd_any=rule
  set firewall.${FIREWALLZONE}_fwd_any.name=Reject-${NETWORKID}-Unmatched-Forward
  set firewall.${FIREWALLZONE}_fwd_any.proto='all'
  set firewall.${FIREWALLZONE}_fwd_any.src=${NETWORKID}
  set firewall.${FIREWALLZONE}_fwd_any.dest='*'
  set firewall.${FIREWALLZONE}_fwd_any.target=REJECT

  delete wireless.${NETWORKID}_radio0

  set wireless.${NETWORKID}_radio0=wifi-iface
  set wireless.${NETWORKID}_radio0.device='radio0'
  set wireless.${NETWORKID}_radio0.network=${NETWORKID}
  set wireless.${NETWORKID}_radio0.mode='ap'
  set wireless.${NETWORKID}_radio0.ssid=${SSID}5Ghz
  set wireless.${NETWORKID}_radio0.encryption='psk2+ccmp'
  set wireless.${NETWORKID}_radio0.key=${WIFISECRET}
  set wireless.${NETWORKID}_radio0.isolate='1'

  delete wireless.${NETWORKID}_radio1

  set wireless.${NETWORKID}_radio1=wifi-iface
  set wireless.${NETWORKID}_radio1.device='radio1'
  set wireless.${NETWORKID}_radio1.network=${NETWORKID}
  set wireless.${NETWORKID}_radio1.mode='ap'
  set wireless.${NETWORKID}_radio1.ssid=${SSID}
  set wireless.${NETWORKID}_radio1.encryption='psk2+ccmp'
  set wireless.${NETWORKID}_radio1.key=${WIFISECRET}
  set wireless.${NETWORKID}_radio1.isolate='1'
EOF

uci commit && cd /etc/init.d && \
./network restart && \
./dnsmasq restart && \
./firewall reload
