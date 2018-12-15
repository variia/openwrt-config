# https://openwrt.org/docs/guide-quick-start/basic_wifi
# https://openwrt.org/docs/guide-user/network/wifi/basic

# check router capabilities for supported options
# $ iw phy0 info
# $ iw phy1 info
COUNTRY=
CH50=
CH24=
HWMODE50=
HWMODE24=
HTMODE50=
HTMODE24=

# lan zone
NETWORKID=lan
SSID=
WIFISECRET50=
WIFISECRET24=

uci batch <<EOF
  delete wireless.default_radio0
  delete wireless.default_radio1

  set wireless.radio0.country=${COUNTRY}
  set wireless.radio0.channel=${CH50}
  set wireless.radio0.bursting='1'
  set wireless.radio0.ff='1'
  set wireless.radio0.compression='1'
  set wireless.radio0.noscan='0'
  set wireless.radio0.turbo='1'
  set wireless.radio0.hwmode=${HWMODE50}
  set wireless.radio0.htmode=${HTMODE50}
  set wireless.radio0.txpower='20'
  set wireless.radio0.disabled='0'

  set wireless.radio1.country=${COUNTRY}
  set wireless.radio1.channel=${CH24}
  set wireless.radio1.bursting='1'
  set wireless.radio1.ff='1'
  set wireless.radio1.compression='1'
  set wireless.radio1.noscan='0'
  set wireless.radio1.turbo='1'
  set wireless.radio1.hwmode=${HWMODE24}
  set wireless.radio1.htmode=${HTMODE24}
  set wireless.radio1.txpower='20'
  set wireless.radio1.disabled='0'

  delete wireless.${NETWORKID}_radio0

  set wireless.${NETWORKID}_radio0=wifi-iface
  set wireless.${NETWORKID}_radio0.device='radio0'
  set wireless.${NETWORKID}_radio0.network=${NETWORKID}
  set wireless.${NETWORKID}_radio0.mode='ap'
  set wireless.${NETWORKID}_radio0.ssid=${SSID}5Ghz
  set wireless.${NETWORKID}_radio0.encryption='psk2+ccmp'
  set wireless.${NETWORKID}_radio0.key=${WIFISECRET50}
  set wireless.${NETWORKID}_radio0.isolate='0'

  delete wireless.${NETWORKID}_radio1

  set wireless.${NETWORKID}_radio1=wifi-iface
  set wireless.${NETWORKID}_radio1.device='radio1'
  set wireless.${NETWORKID}_radio1.network=${NETWORKID}
  set wireless.${NETWORKID}_radio1.mode='ap'
  set wireless.${NETWORKID}_radio1.ssid=${SSID}
  set wireless.${NETWORKID}_radio1.encryption='psk2+ccmp'
  set wireless.${NETWORKID}_radio1.key=${WIFISECRET24}
  set wireless.${NETWORKID}_radio1.isolate='0'
EOF

uci commit && cd /etc/init.d && ./network restart && ./firewall reload
