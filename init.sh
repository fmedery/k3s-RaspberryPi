#!/usr/bin/env bash
#set -x
set -e

#############
# variables #
#############

# you will need to update some variables below
#volume_path="/Volume"
#volume_name="NO NAME"
#sd_card_name="${volume_path}/${volume_name}"
sd_card_name="$(mount |grep NAME | awk '{print $3" "$4}')"

# I use 32 GB SC CARD so I cheated to get device name
sd_card_device="/dev/$(diskutil list | egrep  '3.\.. GB.* disk.$' | awk '{print $5}')"


domainname="local"
hostname="${HOSTNAME}"
ip="${IP}"
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

root_ssh_pubkey="${ROOT_SSH_PUBKEY}"

script="./$(basename $0)"

################
# Basic checks #
################

if [ -z ${HOSTNAME} ] || [ -z ${IP} ] || [ -z "${ROOT_SSH_PUBKEY}" ]; then
    echo "you need to export 3 variables."
    echo ""
    echo "Usage:"
    echo "export HOSTNAME=\"hostname\""
    echo "export IP=\"ip\""
    echo "ROOT_SSH_PUBKEY=\'PUBLIC KEY\'"
    echo "./$(basename $0)"
    exit 1
fi

if [ ! -d "${sd_card_name}" ]; then
    echo "error: ${sd_card_name} not found."
    echo ""
    echo "possible causes:"
    echo "  * SD CARD is not mounted or raspbian image has to been burned on the SD CARD yet"
    echo "  * If you are not on a Mac you need to change variable \$volume_path in ${script}"
    echo ""
    echo "Check README.md for more info"
    exit 1
fi


########
# Main #
########

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

root_ssh_pubkey="${root_ssh_pubkey}"

# vim: set ft=config:

EOF
# copy post installation command
echo "copy post installation command"
echo "cp post-install.txt "${sd_card_name}"/raspberrypi-ua-netinst/config/post-install.txt"
cp post-install.txt "${sd_card_name}"/raspberrypi-ua-netinst/config/post-install.txt

echo ""
echo "ejecting ${sd_card_device}"
diskutil eject ${sd_card_device}

echo ""
echo "all done."
echo " install the SD CARD in the Raspberry"
echo "Installation will take up to 15 minutes"
echo "you will be able to connect to ${hostname}.${domainname}"
echo "ssh -l root ${hostname}.${domainname}"
echo ""
echo "if ssh auth using ssh key fail, the default root password: raspbian"

# vim: set ft=sh:
