# https://blog.cloudflare.com/dns-over-tls-for-openwrt
# https://openwrt.org/docs/guide-user/services/dns/unbound
# https://github.com/openwrt/packages/blob/master/net/unbound/files/README.md

NETWORKID=lan
FIREWALLZONE=${NETWORKID}
UNBOUND_CONF="/etc/unbound/unbound_ext.conf"
UNBOUND_PORT=5353

opkg update

test -n "$(opkg list-installed unbound-daemon-heavy)" || opkg install unbound-daemon-heavy
test -n "$(opkg list-installed luci-app-unbound)" || opkg install luci-app-unbound

# remove all config except default headers
cp ${UNBOUND_CONF} ${UNBOUND_CONF}.old
sed '/^[a-z ].*/d' ${UNBOUND_CONF}.old > ${UNBOUND_CONF}

# append CF config
cat >> ${UNBOUND_CONF} << EOF
forward-zone:
  name: "."
  forward-addr: 1.1.1.1@853
  forward-addr: 1.0.0.1@853
  forward-addr: 2606:4700:4700::1111@853
  forward-addr: 2606:4700:4700::1001@853
  forward-ssl-upstream: yes
EOF

uci batch <<EOF
  set unbound.@unbound[0].add_local_fqdn='0'
  set unbound.@unbound[0].add_wan_fqdn='0'
  set unbound.@unbound[0].dhcp_link='none'
  set unbound.@unbound[0].domain='lan'
  set unbound.@unbound[0].domain_type='refuse'
  set unbound.@unbound[0].listen_port=${UNBOUND_PORT}
  set unbound.@unbound[0].rebind_protection='1'
  set unbound.@unbound[0].enabled='1'

  delete firewall.${FIREWALLZONE}_unbound

  set firewall.${FIREWALLZONE}_unbound=rule
  set firewall.${FIREWALLZONE}_unbound.name='Reject-${NETWORKID}-Unbound-DNS'
  set firewall.${FIREWALLZONE}_unbound.proto='tcpudp'
  set firewall.${FIREWALLZONE}_unbound.src=${NETWORKID}
  set firewall.${FIREWALLZONE}_unbound.dest_port='${UNBOUND_PORT}'
  set firewall.${FIREWALLZONE}_unbound.target='REJECT'

  add_list dhcp.@dnsmasq[0].server='127.0.0.1#${UNBOUND_PORT}'
  add_list dhcp.@dnsmasq[0].server='::1#${UNBOUND_PORT}'
EOF

uci commit && cd /etc/init.d && \
./unbound enable && ./unbound restart && \
./dnsmasq enable && ./dnsmasq restart && \
./firewall reload
