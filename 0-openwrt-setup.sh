# https://openwrt.org/docs/guide-user/base-system/start
# https://openwrt.org/docs/guide-user/network/start
# https://openwrt.org/docs/guide-user/firewall/start
# https://openwrt.org/docs/guide-user/security/lede_security

HOSTNAME=
ZONENAME=
TIMEZONE=
SUBNET=
MASK=
PPPOEUSER=
PPPOEPASS=

opkg update

test -n "$(opkg list-installed luci-ssl)" || opkg install luci-ssl

uci batch <<EOF
  set system.@system[0].zonename=${ZONENAME}
  set system.@system[0].timezone=${TIMEZONE}
  set system.@system[0].hostname=${HOSTNAME}

  set network.lan.proto='static'
  set network.lan.ipaddr=${SUBNET}
  set network.lan.netmask=${MASK}

  set network.wan.proto='pppoe'
  set network.wan.username=${PPPOEUSER}
  set network.wan.password=${PPPOEPASS}
  set network.wan.keepalive='5 5'
  set network.wan.persist='1'
  set network.wan.holdoff='5'

  delete uhttpd.main.listen_http

  set firewall.@defaults[0].custom_chains='1'
  set firewall.@defaults[0].drop_invalid='1'
  set firewall.@defaults[0].syn_flood='1'
  set firewall.@defaults[0].synflood_burst='50'
  set firewall.@defaults[0].synflood_protect='1'
  set firewall.@defaults[0].tcp_ecn='1'
  set firewall.@defaults[0].tcp_syncookies='1'
  set firewall.@defaults[0].tcp_window_scaling='1'
  set firewall.@defaults[0].disable_ipv6='0'

  set dropbear.@dropbear[0].Interface='lan'
  set dropbear.@dropbear[0].BannerFile='/etc/banner'

  set dhcp.@dnsmasq[0].localservice='1'
  set dhcp.@dnsmasq[0].port='53'
  set dhcp.@dnsmasq[0].cachesize='1000'
  set dhcp.@dnsmasq[0].dnsforwardmax='1000'
  set dhcp.@dnsmasq[0].nohosts='1'
  set dhcp.@dnsmasq[0].noresolv='1'
EOF

uci commit && cd /etc/init.d && \
./uhttpd disable && \
./system reload && \
./network restart && \
./sysntpd reload && \
./dnsmasq enable && ./dnsmasq restart && \
./firewall reload
