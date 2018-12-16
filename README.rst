==============
openwrt-config
==============

My custom OpenWrt configuration

Features
========
* Hardened for additional security
* Privacy focused DNS from `CloudFare <https://blog.cloudflare.com/dns-over-tls-for-openwrt>`_
* Isolated Guest Wi-Fi LAN
* Isolated Kids Wi-Fi LAN with parental control by OpenDNS (account required)
* OpenDNS DDNS support for dynamic IPs

Prerequisites
=============
* openwrt supported router

.. code:: yaml

    recommended:
      - Linksys WRT1900AC (tested)
      - Linksys WRT1900ACS
      - Linksys WRT3200ACM

* openwrt or LEDE firmware

.. code:: yaml

    tested:
      - OpenWrt 18.06.1, r7258-5eb055306f
      - LEDE Reboot 17.01.4, r3560-79f57e422d

Note:
=====
I created this repo for myself, the code is written to suit my needs. I made it
public to share knowledge and help others trying to achieve similar goals.

You are welcome to clone it and/or cherry pick just what you need, but pull requests
are discouraged, since it is not meant to be a collaboration project as of today.

Most of the config assumes fresh install or mostly system defaults. Running these
over already customised systems may render your router unbootable, or inaccessible.

**DO NOT USE code from this repo without understanding it, I take NO RESPONSIBILITY
for your loss, YOU HAVE BEEN WARNED!**

You will be required to edit these files to suit your needs, firewall, network
skills are essential.

You will also need some shell experience, to be able to upload the files to your
router as they need to run locally on the device.

The scripts are numbered to indicate order of importance as well as dependency.
Some of them rely on settings already in place and/or loaded by another script.

The ``SUBNET`` variable is actually an IP address of a subnet you want to assign to
the router. The ``MASK`` is, what will define the subnet length and the available
addresses in it, which will be served by the router. While I understand, that it is a
bit confusing, I thought it is better than any other I could come up with at the time.

The scripts are not executable on purpose, you can always pass them as shell arguments:

.. code::

    # sh <scriptname>

Some errors such as ``uci: Entry not found`` are expected. Examine config files
after script run and ensure desired settings are in place for all affected services.

Available scripts
=================

.. contents::
    :local:

``0-openwrt-setup.sh``
----------------------

Initial config, should be executed straight after install or upgrade.

**TODO**:
Must fill the following variables:

.. code::

    HOSTNAME=
    ZONENAME=
    TIMEZONE=
    SUBNET=
    MASK=

**Note:**
 * ``ZONENAME/TIMEZONE`` are for `NTP <https://openwrt.org/docs/guide-user/base-system/system_configuration>`_ .

 * IF you change the default ``lan`` subnet address, expect the script not
   to exit cleanly as networking will be interrupted. Restart your system's
   networking to get a new IP address and log back into the router again.

 * ``luci-ssl`` is default, standard HTTP service is removed completely.

 * For additional safety, the ``luci-ssl`` **Web-UI** is disabled by default,
   it won't even start after reboot.

   To re-enable and/or restart:

.. code::

    # cd /etc/init.d && ./uhttpd enable && ./uhttpd restart

``1-openwrt-wifi.sh``
---------------------

Default 2.4Ghz and 5Ghz Wi-Fi networks that use CloudFare's DNS.

**TODO**:
Must fill the following variables:

.. code::

    COUNTRY=
    CH50=
    CH24=
    HWMODE50=
    HWMODE24=
    HTMODE50=
    HTMODE24=
    SSID=
    WIFISECRET50=
    WIFISECRET24=

**Note:**
 * ``COUNTRY`` is your `regulatory domain <https://openwrt.org/docs/guide-user/network/wifi/wifi_countrycode>`_ .

 * ``CH50/CH24`` preferred channel for 2.4Ghz and 5Ghz. These depend on you regulatory domain (COUNTRY)
   and the area you are in. I found OpenWrt routers perform much better on manual channels than on ``auto``.

 * ``HWMODE50/HWMODE24`` are `router AP modes <https://openwrt.org/docs/guide-user/network/wifi/basic>`_ .
   Again, setting these to specifics like ``11g`` for 2.4Ghz and ``11a`` for 5Ghz will give you better
   performance, but these may not work with all devices. (especially if old)

 * ``HTMODE50/HTMODE24`` are ` channel width in 802.11n and 802.11ac mode <https://openwrt.org/docs/guide-user/network/wifi/basic>`_ , and very much depend on your hardware.

 * ``WIFISECRET50/WIFISECRET24`` define different passphrase for 2.4Ghz and 5Ghz networks.

 * It is assumed that ``radio0`` is 5Ghz and ``radio1`` is 2.4Ghz network.

 * Examine the settings for both networks and modify them to your needs as these are
   heavily customised for ``Linksys WRT1900AC`` router series.

``2-openwrt-unbound.sh``
------------------------

CloudFare's *DNS over TLS* service with Unbound DNS server.

**Note:**
 * For sake of simplicity and compatibility, it is based on `serial dnsmasq <https://github.com/openwrt/packages/tree/master/net/unbound/files#serial-dnsmasq>`_ setup.

 * Firewall rules are added to block unbound access over the network as ``unbound``
   should only be a forwarding upstream for ``dnsmasq`` on localhost.

``3-openwrt-guest-lan.sh``
--------------------------

Isolated **Guest** Wi-Fi networks. (additional)

**TODO**:
Must fill the following variables:

.. code::

    SUBNET=
    MASK=
    SSID=
    WIFISECRET=

**Note:**
 * ``WIFISECRET`` define the same passphrase for both, 2.4Ghz and 5Ghz networks.

 * It is assumed that ``radio0`` is 5Ghz and ``radio1`` is 2.4Ghz network.

 * Firewall rules are added to prevent savvy user trying to bypass DNS service.

 * Firewall rules are added to block forwarded traffic to RFC1918 private subnets
   over the wan interface. This is to support setups where the OpenWrt router is
   connected to ISP Modem/Router over private link. (double-nat)

 * Network services are limited to the following ports by default:

.. code::

    SMTP (25)
    HTTP (80)
    NTP (123)
    HTTPS (443)
    SMTPS (465)
    SUBMISSION (587)
    IMAP4S (993)
    POP3S (995)

``4-openwrt-kids-lan.sh``
-------------------------

Isolated **Kids** Wi-Fi network (additional) with parental control by
*OpenDNS Home Internet Security* service. (default)

**TODO**:
Must fill the following variables:

.. code::

    SUBNET=
    MASK=
    SSID=
    WIFISECRET=

**Note:**
 * DO NOT skip EDUCATING your kids, this solution just helps to use the Internet safely.

 * ``WIFISECRET`` define the same passphrase for both, 2.4Ghz and 5Ghz networks.

 * It is assumed that ``radio0`` is 5Ghz and ``radio1`` is 2.4Ghz on your network.

 * By default, this DNS is wide open hence you need an OpenDNS account, to be able to
   customise what the DNS filters.

 * Once you have an account, you can create networks like IPs, subnets, etc. and setup
   what categories are allowed or blocked for each network. You can have multiple networks
   for a single account like HOME, OFFICE, etc.

 * Networks are identified by a **label**

 * Firewall rules are added to prevent savvy user trying to bypass DNS service.

 * Firewall rules are added to block forwarded traffic to RFC1918 private subnets
   over the wan interface. This is to support setups where the OpenWrt router is
   connected to ISP Modem/Router over private link. (double-nat)

 * There will be certificate warnings about accessing HTTPS websites which are normal,
   fix is available here: `*.opendns.com Certificate errors - Adding Exceptions <https://support.opendns.com/hc/en-us/articles/227988767--opendns-com-Certificate-errors-Adding-Exceptions>`_

 * `OpenDNS FamilyShield <https://support.opendns.com/hc/en-us/articles/228006487-FamilyShield-Router-Configurationnstructions>`_

 * `OpenDNS Home Free <https://www.opendns.com/home-internet-security/>`_

 * Network services are limited to the following ports by default:

.. code::

    SMTP (25)
    HTTP (80)
    NTP (123)
    HTTPS (443)
    SMTPS (465)
    SUBMISSION (587)
    IMAP4S (993)
    POP3S (995)

``5-openwrt-opendns.sh``
------------------------

OpenDNS DDNS service to update the IP address for the given network label (service).

**TODO**:
Must fill the following variables:

.. code::

    DDNS_USER=
    DDNS_PASS=
    DDNS_LABEL=

**Note:**
 * ``DDNS_USER/DDNS_PASS`` are your OpenDNS account credentials, the same you use to log in
   to your account over the web.

 * ``DDNS_LABEL`` identifies your network within your OpenDNS account.

 * Errors like ``WARN : Service section disabled! - TERMINATE`` are normal, the default ``ddns``
   config is responsible for this. This should disappear after the script is run.
