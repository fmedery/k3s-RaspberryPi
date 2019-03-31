# Introduction

* I want to create a kubernetes cluster using k3s on multiple Raspberry Pi 3 Model B+.
* k3s doesn't support master HA at the moment https://github.com/rancher/k3s#server-ha
* I will create 1 master and 3 workers.
* I want to be able to speed up the process of installing and configuring the OS on each SD CARD.
* I install zeronf package to be able to connect to each node easily.
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
* Download the latest `raspberrypi-ua-netinst img.bz2`: https://github.com/FooDeas/raspberrypi-ua-netinst/releases
* Disable `Auto-unmount on success` in balenaEtcher's settings.

# Create the master node

## Create the unattended config

``` sh
export HOSTNAME="<master hostname>"
export MASTER_IP="<master IP>"
export IP=${MASTER_IP}
export ROOT_SSH_PUBKEY="<YOUR SSH PUBLIC KEY>"

./init.sh
```
## Burn image

* Use balenaEtcher to burn `raspberrypi-ua-netinst.img.bz2` on the SD card.

## install Raspberry Pi

* Start the raspbery Pi with the master SD card.
* When ready test ssh connectivity:
``` sh
ssh -l root ${HOSTNAME}.local -t hostname
```
## Install k3s

```sh
ssh -l root master.local <<-\SSH
# install k3s
curl -sfL https://get.k3s.io | sh -
SSH
```
* test if kubernetes is up
```sh
ssh -l root master.local "k3s kubectl get node"
```
* get kubernets token to authenticate workers when joining
```sh
export K3S_TOKEN=$(ssh -l root master.local "cat /var/lib/rancher/k3s/server/node-token")
```
# Create workers nodes

* We will create:
    * worker1
    * worker2
    * worker3

## Create unattended config file

* run 
``` sh
export HOSTNAME="<worker 1,2 or 3>"
export IP="<worker IP>"
export ROOT_SSH_PUBKEY="<YOUR SSH PUBLIC KEY>"

./init.sh
```

## Burn image

* Disable "Auto-unmount on success" in balenaEtcher settings.
* Use balenaEtcher to burn `raspberrypi-ua-netinst.img.bz2` on the SD card.

## install Raspberry Pi

* Start the raspbery Pi with the master SD card
* it takes around 10 minutes for the installation to be finished
* When ready test ssh connectivity:
``` sh
ssh -l root ${HOSTNAME}.local hostname
```

## Install k3s

* install k3s
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
