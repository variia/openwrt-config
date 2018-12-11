# https://openwrt.org/docs/guide-user/security/lede_security

opkg update

test -n "$(opkg list-installed luci-ssl)" || opkg install luci-ssl

uci batch <<EOF
  delete uhttpd.main.listen_http

  set firewall.@defaults[0].custom_chains='1'
  set firewall.@defaults[0].drop_invalid='1'
  set firewall.@defaults[0].syn_flood='1'
  set firewall.@defaults[0].synflood_burst='50'
  set firewall.@defaults[0].synflood_protect='1'
  set firewall.@defaults[0].tcp_ecn='1'
  set firewall.@defaults[0].tcp_syncookies='1'
  set firewall.@defaults[0].tcp_window_scaling='1'

  delete dhcp.@dnsmasq[0]

  add dhcp dnsmasq

  set dhcp.@dnsmasq[0].domainneeded='1'
  set dhcp.@dnsmasq[0].boguspriv='1'
  set dhcp.@dnsmasq[0].filterwin2k='0'
  set dhcp.@dnsmasq[0].localise_queries='1'
  set dhcp.@dnsmasq[0].rebind_protection='1'
  set dhcp.@dnsmasq[0].rebind_localhost='1'
  set dhcp.@dnsmasq[0].local='/lan/'
  set dhcp.@dnsmasq[0].domain='lan'
  set dhcp.@dnsmasq[0].expandhosts='1'
  set dhcp.@dnsmasq[0].nonegcache='1'
  set dhcp.@dnsmasq[0].authoritative='1'
  set dhcp.@dnsmasq[0].readethers='1'
  set dhcp.@dnsmasq[0].leasefile='/tmp/dhcp.leases'
  set dhcp.@dnsmasq[0].resolvfile='/tmp/resolv.conf.auto'
  set dhcp.@dnsmasq[0].localservice='1'
  set dhcp.@dnsmasq[0].port='53'
  set dhcp.@dnsmasq[0].cachesize='1000'
  set dhcp.@dnsmasq[0].dnsforwardmax='1000'
  set dhcp.@dnsmasq[0].nohosts='1'
  set dhcp.@dnsmasq[0].noresolv='1'

  delete dhcp.lan

  set dhcp.lan=dhcp
  set dhcp.lan.interface='lan'
  set dhcp.lan.start='100'
  set dhcp.lan.leasetime='12h'
  set dhcp.lan.dhcpv6='server'
  set dhcp.lan.ra='server'
  set dhcp.lan.ra_management='1'
  set dhcp.lan.limit='150'

  delete dhcp.wan

  set dhcp.wan=dhcp
  set dhcp.wan.interface='wan'
  set dhcp.wan.ignore='1'

  delete dhcp.odhcpd

  set dhcp.odhcpd=odhcpd
  set dhcp.odhcpd.maindhcp='0'
  set dhcp.odhcpd.leasefile='/tmp/hosts/odhcpd'
  set dhcp.odhcpd.leasetrigger='/usr/sbin/odhcpd-update'
EOF

uci commit && cd /etc/init.d && ./uhttpd disable && ./dnsmasq enable && ./dnsmasq restart && ./odhcpd enable && ./odhcpd restart && ./firewall reload
