#!/usr/bin/env bash
#set -x
set -e

###
# script create the unattended config file and needs 2 variables
# $1 variable is the hostname
# $2 is the ip address
#
# you will neeed to edit some variables
###

# simple check for $1 and $2
if [ -z ${1} ] || [ -z $2 ]; then
    echo "script needs 2 variables"
    echo ""
    echo "$(basename $0) HOSTNAME IP "
    echo ""
    echo "exit"
    exit 1
fi

## variables
# path is always the same on a Mac
sd_card_name="/Volumes/NO NAME"


# most of the variables below need to be updated !
sd_card_device="/dev/disk4"
domainname="local"
ip_range="192.168.7"
ip_netmask="255.255.255.0"
ip_gateway="${ip_range}.1"
ip_nameservers="${ip_range}.1"
timezone="America/Toronto"
wlan_country="CA"
keyboard_layout="us"
locales="en_US.UTF-8,en_US,en_CA.UTF-8"
system_default_locale="en_CA.UTF-8"
packages="libnss-mdns,vim,sudo,curl,htop"

hostname="${1}"
ip="${2}"

# create installer-config.txt
echo "create "${sd_card_name}"/raspberrypi-ua-netinst/config/installer-config.txt"
cat << EOF > "${sd_card_name}"/raspberrypi-ua-netinst/config/installer-config.txt
# installed lots of usefull packages 
preset=server

# install additional packages
packages=${packages}

# Set to "1" to install common firmware packages (Atheros, Broadcom, Libertas, Ralink and Realtek).
firmware_packages=1

# add docker specifics
cmdline="dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 elevator=deadline fsck.repair=yes cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"

timezone=${timezone}

hostname=${hostname}
domainname=${domainname}

wlan_country=${wlan_country}

ip_addr=${ip}
ip_netmask=${ip_netmask}
ip_gateway=${ip_gateway}
ip_nameservers=${ip_nameservers}
ip_ipv6=0

keyboard_layout=${keyboard_layout}
locales=${locales}
system_default_locale=${system_default_locale}

# set the minimum of GPU RAM
gpu_mem=16

# vim: set ft=config:

EOF

echo ""
echo "ejecting ${sd_card_device}"
diskutil eject ${sd_card_device}

echo ""
echo "all done. Installation will take up to 10 minutes"
echo "you will be able to connect to ${hostname}.${domainname}"
echo "ssh -l root ${hostname}.${domainname}"
echo ""
echo "default root password: raspbian"

# vim: set ft=sh:
