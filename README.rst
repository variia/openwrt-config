==============
openwrt-config
==============

My custom openwrt configuration based on ``uci`` commands, wrapped in ordered shell
scripts.

Features
========
* ordered shell wrapper scripts that are not executable for safety
* hardened settings for additional security
* Privacy focused DNS from `CloudFare <https://blog.cloudflare.com/dns-over-tls-for-openwrt>`_
* Isolated Guest Wi-Fi LAN with `OpenDNS FamilyShield <https://support.opendns.com/hc/en-us/articles/228006487-FamilyShield-Router-Configuration-Instructions>`_
* Isolated Kids Wi-Fi LAN with `OpenDNS Home Free <https://www.opendns.com/home-internet-security/>`_ (account required)
* OpenDNS DDNS support for dynamic IPs

Prerequisites
=============
* openwrt supported router

.. code:: yaml

    recommended:
      - Linksys WRT1900AC
      - Linksys WRT1900ACS
      - Linksys WRT3200ACM

* openwrt or LEDE firmware

.. code:: yaml

    tested:
      - Reboot (17.01.4, r3560-79f57e422d)

Note:
=====
You will need some shell experince, to be able to upload the files to your router
as they need to run locally on the device.

The scripts are numbered to indicate order of importance. Some of them rely on
settings already in place and/or loaded by another script.

The scripts are not executable on purpose, you can always pass them as shell arguments:

.. code::

    # sh <scriptname>

Available scripts
=================

.. contents::
    :local:

``1-openwrt-setup.sh``
----------------------

Base or inital config, should be executed straight after install or upgrade.

``2-openwrt-unbound.sh``
------------------------

Installs CloudFare's DNS over TLS with Unbound.

**Note:** for sake of simplicity and compatibility, it is based on
`serial dnsmasq <https://github.com/openwrt/packages/tree/master/net/unbound/files#serial-dnsmasq>`_ setup.

``3-openwrt-guest-lan.sh``
--------------------------

Installs an isolated **Guest** Wi-Fi network (additional) that uses *OpenDNS FamilyShield* service.

**TODO**:
you will have to edit the script prior execution and fill the following variables accordingly:

.. code::

    NETWORKID=
    SUBNET=
    MASK=
    WIFISECRET=

**Note:**
 * firewall rule(s) are added to prevent savvy user(s) trying to bypass DNS service
 * network services are limited to the following ports only:

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

Installs an isolated **Kids** Wi-Fi network (additional) that uses *OpenDNS Home Internet Security* service.

**TODO**:
you will have to edit the script prior execution and fill the following variables accordingly:

.. code::

    NETWORKID=
    SUBNET=
    MASK=
    WIFISECRET=

**Note:**
 * by default, this DNS is wide open!! you need an OpenDNS account, to be able to customise
   what the DNS allows or blocks
 * once you have an account, you can create network(s) (like IPs, subnets, etc) and setup
   what categories are allowed or blocked for each network. you can have multiple networks
   for a single account, like HOME, OFFICE, etc. each network is identified by a *label*
 * firewall rule(s) are added to prevent savvy user(s) trying to bypass DNS service
 * network services are limited to the following ports only:

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

Installs OpenDNS DDNS service to update the IP address for the given network (service) label.

**TODO**:
you will have to edit the script prior execution and fill the following variables accordingly:

.. code::

    DDNS_USER=
    DDNS_PASS=
    DDNS_LABEL=
