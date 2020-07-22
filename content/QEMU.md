Title: Host only networking set up for QEMU
Date: 24.03.2017
Modified: 01.03.2020
Author: Andrey Albershtein
Status: published
Tags: qemu, linux, networking
Keywords: qemu, linux, network, host-guest
Summary: In this short note I will try to describe how to set up host-only network for QEMU. It means that guest system (run in QEMU) will be in LAN network with a host system (physical machine).

In this short note I will try to describe how to set up host-only network for QEMU
hypervisor. It means that guest system (run in QEMU) will be in LAN network
with a host system (physical machine). I used it for some experiments with SSH 
functionality of a guest system.

Connection will be establish by virtual bridge and TAP interface. After host
setup you will need to assign IP address to the guest system.

Firstly, create a bridge on the host machine:

```sh
sudo ip link add br0 type bridge
```

If you want to use already created bridge don't forget to clean out IP.

```sh
sudo ip addr flush dev br0
```

Assign IP to the bridge.

```sh
sudo ip addr add 192.168.100.50/24 brd 192.168.100.255 dev br0
```

Create TAP interface.

```sh
sudo ip tuntap add mode tap user $(whoami)
ip tuntap show
```

Output should contains name of created TAP interface:

```sh
~ tap0: tap UNKNOWN_FLAGS:800 user 1000
```

Add TAP interface to the bridge.

```sh
sudo ip link set tap0 master br0
```

Make sure everything is up:

```sh
sudo ip link set dev br0 up
sudo ip link set dev tap0 up
```

Assign IP range to the bridge.

```sh
sudo dnsmasq --interface=br0 --bind-interfaces \
    --dhcp-range=192.168.100.50,192.168.100.254
```

Make sure that interfaces are UP. If not run previously mentioned commands to set
TAP interface up (br0 will change its state automatically). Run Qemu with some
MAC address:

```sh
qemu -device e1000,netdev=network0,mac=00:00:00:00:00:00 \
        -netdev tap,id=network0,ifname=tap0,script=no,downscript=no
```

In the guest system assign static IP address to the network interface:

```sh
ip addr add 192.168.100.224/24 broadcast 192.168.100.255 dev eth0
```

Don't forget to add root password:

```sh
passwd
```

Now you can connect to the Qemu guest system using SSH:

```
ssh root@192.168.100.224
```

#### Troubleshooting

If you get an error that tap0 is already in use, possibly, you are trying to run
more than one version of QEMU for one TAP interface. Described configuration is
used only for two peers (host and guest). For multiple connection you need
different configuration.

As mentioned before make sure that both TAP and Bridge are up.  Otherwise you
will fail to connect via SSH.

#### References

- [QEMU?](http://www.qemu-project.org/)
- [TUN/TAP?](https://en.wikipedia.org/wiki/TUN/TAP)
