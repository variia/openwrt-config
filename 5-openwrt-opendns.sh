# https://openwrt.org/docs/guide-user/base-system/ddns
# https://openwrt.org/docs/guide-user/services/ddns/client
# https://github.com/openwrt/packages/blob/master/net/ddns-scripts/files/services

CA_DIR="/etc/ssl/certs"
CA_CRT="${CA_DIR}/ca-certificates.crt"
CA_SRC="http://curl.haxx.se/ca/cacert.pem"
IP_URL="https://diagnostic.opendns.com/myip"

DDNS_SERVICE="opendns.com"
DDNS_USER=
DDNS_PASS=
DDNS_LABEL=

opkg update

test -n "$(opkg list-installed wget)" || opkg install wget
test -n "$(opkg list-installed ddns-scripts)" || opkg install ddns-scripts

test -d ${CA_DIR} || mkdir -p -m0755 ${CA_DIR}
test -f ${CA_CRT} || wget --no-check-certificate -O ${CA_CRT} ${CA_SRC}

uci batch <<EOF
  delete ddns.myddns_ipv4
  delete ddns.myddns_ipv6

  delete ddns.opendns_ipv4

  set ddns.opendns_ipv4='service'
  set ddns.opendns_ipv4.service_name=${DDNS_SERVICE}
  set ddns.opendns_ipv4.domain=${DDNS_LABEL}
  set ddns.opendns_ipv4.username=${DDNS_USER}
  set ddns.opendns_ipv4.password=${DDNS_PASS}
  set ddns.opendns_ipv4.interface='wan'
  set ddns.opendns_ipv4.use_https='1'
  set ddns.opendns_ipv4.cacert=${CA_CRT}
  set ddns.opendns_ipv4.enabled='1'
  set ddns.opendns_ipv4.ip_source='web'
  set ddns.opendns_ipv4.ip_url=${IP_URL}
EOF

uci commit ddns && cd /etc/init.d && ./ddns enable && ./ddns restart
