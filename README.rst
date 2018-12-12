==============
openwrt-config
==============

My custom openwrt configuration.

Features
========
* hardened for additional security
* Privacy focused DNS from `CloudFare <https://blog.cloudflare.com/dns-over-tls-for-openwrt>`_
* Isolated Guest Wi-Fi LAN with `OpenDNS FamilyShield <https://support.opendns.com/hc/en-us/articles/228006487-FamilyShield-Router-Configuration-Instructions>`_
* Isolated Kids Wi-Fi LAN with parental control by `OpenDNS Home Free <https://www.opendns.com/home-internet-security/>`_ (account required)
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
I created this repo for myself, the code is written to suit my needs. I made it
public to share knowledge and help others trying to achieve similar goals.

You are welcome to clone it and/or cherry pick just what you need, but pull requests
are discouraged, since it is not meant to be a collaboration project as of today.

Most of the config assumes fresh install or mostly system defaults. Running these
over already customised systems may render your router unbootable, or inaccessible.

DO NOT USE code from this repo without understanding it, I take NO RESPONSIBILITY
for your loss, YOU HAVE BEEN WARNED!

You will be required to edit these files to suit your needs, firewall, network
skills are essential.

You will also need some shell experience, to be able to upload the files to your
router as they need to run locally on the device.

The scripts are numbered to indicate order of importance as well as dependency.
Some of them rely on settings already in place and/or loaded by another script.

The scripts are not executable on purpose, you can always pass them as shell arguments:

.. code::

    # sh <scriptname>

Available scripts
=================

.. contents::
    :local:

``1-openwrt-setup.sh``
----------------------

Initial config, should be executed straight after install or upgrade.

**Note:**
 * This installs ``luci-ssl`` and removes the standard HTTP service completely.

 * For additional safety, the ``luci-ssl`` **Web-UI** will be disabled by default,
   it won't even start after reboot.

   To re-enable and/or restart:

.. code::

    # cd /etc/init.d && ./uhttpd enable && ./uhttpd restart

``2-openwrt-unbound.sh``
------------------------

Installs CloudFare's *DNS over TLS* service with Unbound DNS server.

**Note:**
 * for sake of simplicity and compatibility, it is based on `serial dnsmasq <https://github.com/openwrt/packages/tree/master/net/unbound/files#serial-dnsmasq>`_ setup.

 * firewall rule(s) are added to block unbound network access as ``unbound`` should
   only be a forwarding upstream for ``dnsmasq`` on localhost.

``3-openwrt-guest-lan.sh``
--------------------------

Installs an isolated **Guest** Wi-Fi network (additional) that uses *OpenDNS FamilyShield* service.

**TODO**:
you will have to edit the script prior execution and fill the following variables accordingly:

.. code::

    SUBNET=
    MASK=
    SSID=
    WIFISECRET=

**Note:**
 * it is assumed that ``radio0`` is 5Ghz and ``radio1`` is 2.4Ghz network.
 * firewall rule(s) are added to prevent savvy user(s) trying to bypass DNS service.
 * firewall rule(s) are added to block forwarded traffic to RFC1918 private subnets
   over the wan interface. this is to support setups where the openwrt router is
   connected to ISP Modem/Router. (double-nat)
 * network services are limited to the following ports by default:

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

Installs an isolated **Kids** Wi-Fi network (additional) with parental control that uses
*OpenDNS Home Internet Security* service.

**TODO**:
you will have to edit the script prior execution and fill the following variables accordingly:

.. code::

    SUBNET=
    MASK=
    SSID=
    WIFISECRET=

**Note:**
 * it is assumed that ``radio0`` is 5Ghz and ``radio1`` is 2.4Ghz network.
 * by default, this DNS is wide open hence you need an OpenDNS account, to be able to
   customise what the DNS filters.
 * once you have an account, you can create network(s) (like IPs, subnets, etc) and setup
   what categories are allowed or blocked for each network. you can have multiple networks
   for a single account, like HOME, OFFICE, etc. each network is identified by a *label*
 * firewall rule(s) are added to prevent savvy user(s) trying to bypass DNS service
 * firewall rule(s) are added to block forwarded traffic to RFC1918 private subnets
   over the wan interface. this is to support setups where the openwrt router is
   connected to ISP Modem/Router. (double-nat)
 * network services are limited to the following ports by default:

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

Installs OpenDNS DDNS service to update the IP address for the given network label (service).

**TODO**:
you will have to edit the script prior execution and fill the following variables accordingly:

.. code::

    DDNS_USER=
    DDNS_PASS=
    DDNS_LABEL=
