# Introduction

* I want to create a kubernetes cluster using k3s on multiple Raspberry Pi 3 Model B+.
* k3s doesn't support master HA at the moment https://github.com/rancher/k3s#server-ha
* I will create 1 master and 3 workers.
* I want to be able to speed up the process of installing and configuring the OS on each SD card.
* I install `zeronf` to be able to connect to each node easily.
* I use a Mac.
* I live in Canada so the hardware can be bought in Canada.

# Hardware

* Raspberry Pi 3 Model B+:
    * https://www.buyapi.ca/
    * https://www.canakit.com/

* Heatsink Cooler:
    * https://www.amazon.ca/dp/B010ER7UN8/ref=pe_3034960_236394800_TE_dp_5

* Switch:
    * https://www.amazon.ca/dp/B00A121WN6/ref=cm_sw_em_r_mt_dp_U_KerOCbHFS5XZ8

* Case:
    * https://www.amazon.ca/ILS-Clear-Acrylic-Cluster-Raspberry/dp/B0768DDTKD

* USB HUB:
    * https://www.amazon.ca/dp/B00YRYS4T4/ref=pe_3034960_236394800_TE_dp_4

* Micro SD card:
    * https://www.amazon.ca/dp/B010Q57T02/ref=pe_3034960_236394800_TE_dp_2

# Pre requis

* Install balenaEtcher https://www.balena.io/etcher/ on your computer.
* Disable `Auto-unmount on success` in balenaEtcher's settings.
* Download the latest `raspberrypi-ua-netinst-v<VERSION>.img.bz2`: https://github.com/FooDeas/raspberrypi-ua-netinst/releases/latest

# Create the master node

## Burn image

* Use balenaEtcher to burn `raspberrypi-ua-netinst-v<VERSION>.img.bz2` on the SD card.

## Create the unattended config

``` sh
export HOSTNAME="<master hostname>"
export MASTER_IP="<master IP>"
export ROOT_SSH_PUBKEY="<YOUR SSH PUBLIC KEY>"
export IP="${MASTER_IP}"
export IP_NETMASK="<Network mask>"      # IP_NETMASK=255.255.255.0 if not set
export IP_GATEWAY="<Network GW IP>"     # IP_GATEWAY=192.168.7.1 if not set
export NAMESERVER="<DNS name server>"   # DNSSERVER=192.168.7.1 if not set
export DOMAIN_NAME="<domain name>"      # DOMAIN_NAME=local if not set
export WLAN_COUNTRY="<WLAN country>"    # WLAN_COUNTRY=CA if not set https://github.com/FooDeas/raspberrypi-ua-netinst/blob/devel/doc/wlan_country.txt
export TZ="<Time zone>"                 # TZ="America/Toronto" if not set https://github.com/FooDeas/raspberrypi-ua-netinst/blob/devel/doc/timezone.txt

./init.sh
```

## install Raspberry Pi

* Start the raspbery Pi with the master SD card.
* It will take around 10 minutes for the installation to complete
* When ready test ssh connectivity:
``` sh
ssh -l root ${HOSTNAME}.local -t hostname
```
## Install k3s

```sh
ssh -l root ${MASTER_IP} <<-\SSH
# install k3s
curl -sfL https://get.k3s.io | sh -
SSH
```
* test if kubernetes is up
```sh
ssh -l root ${MASTER_IP}  "k3s kubectl get node"
```

# Create worker nodes

* We will create:
    * worker1
    * worker2
    * worker3

## Burn image

* Use balenaEtcher to burn `raspberrypi-ua-netinst-v<VERSION>.img.bz2` on the SD card.

## Create unattended config file

``` sh
export HOSTNAME="<worker 1,2 or 3>"
export IP="<worker IP>"
export ROOT_SSH_PUBKEY="<YOUR SSH PUBLIC KEY>"
export IP_NETMASK="<Network mask>" # IP_NETMASK=255.255.255.0 if not set
export IP_GATEWAY="<Network GW IP>" # IP_GATEWAY=192.168.7.1 if not set
export NAMESERVER="<DNS name server>" # DNSSERVER=192.168.7.1 if not set
export DOMAIN_NAME="<domain name>" # DOMAIN_NAME=local if not set

./init.sh
```

## install Raspberry Pi

* Start the raspbery Pi with the master SD card
* It will take around 10 minutes for the installation to complete
* When ready test ssh connectivity:
``` sh
ssh -l root ${HOSTNAME}.local hostname
```

## Install k3s

```sh
export MASTER_IP="<master IP>"
export AUTH_TOKEN=$(ssh -l root ${MASTER_IP} "cat /var/lib/rancher/k3s/server/node-token")

ssh -o SendEnv=MASTER_IP -o SendEnv=AUTH_TOKEN -l root ${HOSTNAME}.local <<-\SSH
# install k3s
curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_IP}:6443 K3S_TOKEN=${AUTH_TOKEN} sh -
SSH
```

## test if worker joined kubernetes cluster

```sh
ssh -l root ${MASTER_IP} "k3s kubectl get node"
```

# Final setup

## master

    hostname: master.local
    ip: 192.168.7.210

## worker1

    hostname: worker1.local
    ip: 192.168.7.211

## worker2

    hostname: worker2.local
    ip: 192.168.7.212

## worker3

    hostname: worker3.local
    ip: 192.168.7.213
