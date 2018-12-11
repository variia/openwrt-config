# https://blog.cloudflare.com/dns-over-tls-for-openwrt/
# https://openwrt.org/docs/guide-user/services/dns/unbound
# https://github.com/openwrt/packages/blob/master/net/unbound/files/README.md

NETWORKID=lan
FIREWALLZONE=${NETWORKID}
UNBOUND_EXT="/etc/unbound/unbound_ext.conf"

opkg update

test -n "$(opkg list-installed unbound)" || opkg install unbound
test -n "$(opkg list-installed luci-app-unbound)" || opkg install luci-app-unbound

# remove all config except headers
cp ${UNBOUND_EXT} ${UNBOUND_EXT}.old
sed '/^[a-z ].*/d' ${UNBOUND_EXT}.old > ${UNBOUND_EXT}

cat >> ${UNBOUND_EXT} << EOF
forward-zone:
  name: "."
  forward-addr: 1.1.1.1@853
  forward-addr: 1.0.0.1@853
  forward-addr: 2606:4700:4700::1111@853
  forward-addr: 2606:4700:4700::1001@853
  forward-ssl-upstream: yes
EOF

uci batch <<EOF
  delete unbound.@unbound[0]

  add unbound unbound

  set unbound.@unbound[0].add_local_fqdn='0'
  set unbound.@unbound[0].add_wan_fqdn='0'
  set unbound.@unbound[0].dhcp_link='none'
  set unbound.@unbound[0].dhcp4_slaac6='0'
  set unbound.@unbound[0].dns64='0'
  set unbound.@unbound[0].domain='lan'
  set unbound.@unbound[0].domain_type='refuse'
  set unbound.@unbound[0].edns_size='1280'
  set unbound.@unbound[0].hide_binddata='1'
  set unbound.@unbound[0].listen_port='5353'
  set unbound.@unbound[0].localservice='1'
  set unbound.@unbound[0].manual_conf='0'
  set unbound.@unbound[0].protocol='mixed'
  set unbound.@unbound[0].query_minimize='0'
  set unbound.@unbound[0].rebind_localhost='0'
  set unbound.@unbound[0].rebind_protection='1'
  set unbound.@unbound[0].recursion='passive'
  set unbound.@unbound[0].resource='small'
  set unbound.@unbound[0].root_age='9'
  set unbound.@unbound[0].ttl_min='120'
  set unbound.@unbound[0].unbound_control='0'
  set unbound.@unbound[0].validator='0'
  set unbound.@unbound[0].enabled='1'

  delete firewall.${FIREWALLZONE}_unbound

  set firewall.${FIREWALLZONE}_unbound=rule
  set firewall.${FIREWALLZONE}_unbound.name='Reject-Unbound-DNS'
  set firewall.${FIREWALLZONE}_unbound.proto='tcpudp'
  set firewall.${FIREWALLZONE}_unbound.src=${FIREWALLZONE}
  set firewall.${FIREWALLZONE}_unbound.dest_port='5353'
  set firewall.${FIREWALLZONE}_unbound.target='REJECT'

  add_list dhcp.@dnsmasq[0].server='127.0.0.1#5353'
  add_list dhcp.@dnsmasq[0].server='::1#5353'
EOF

uci commit && cd /etc/init.d && ./unbound enable && ./unbound restart && ./dnsmasq enable && ./dnsmasq restart && ./firewall reload
