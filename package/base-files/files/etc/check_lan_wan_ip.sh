#!/bin/sh
# filepath: /etc/check_lan_wan_ip.sh

# 获取 LAN/WAN IP
lan_ip=$(uci get network.lan.ipaddr 2>/dev/null)
# 获取 WAN IP（兼容静态和 DHCP）
wan_ip=$(ifstatus wan | jsonfilter -e '@.route[0].nexthop')

lan_prefix=$(echo "$lan_ip" | awk -F. '{print $1"."$2"."$3}')
wan_prefix=$(echo "$wan_ip" | awk -F. '{print $1"."$2"."$3}')

if [ "$lan_prefix" = "$wan_prefix" ]; then
    if [ "$lan_ip" = "192.168.18.1" ]; then
        uci set network.lan.ipaddr='192.168.19.1'
    else
        uci set network.lan.ipaddr='192.168.18.1'
    fi
    uci commit network
    /etc/init.d/network reload
fi
