Title: How to connect HC-05 module to Linux
Date: 21.02.2020
Modified: 21.02.2020
Status: draft
Tags: pelican, publishing
Slug: hc-05-linux
Authors: Andrey Albershtein
Summary: Configure and connect Bluetooth HC-05 module to Linux
lang: en

intro

#### Arduino sketch
- My HC-05 

#### Reconfigure HC-05

- hardware setup
- connect and configure
- remove AT mode wire (not needed implement in software)

#### Back to PC

Install Bluetooth stack

```shell
    $ sudo apt-get install bluez bluez-utils
```

Check if `btusb` is loaded into the kernel:

```shell
    $ lsmod | grep btusb
```

Install generate Bluetooth driver

```shell
    $ sudo apt-get install btusb
```

Start and enable Bluetooth service:

```shell
    $ sudo systemctl enable bluetooth.service
    $ sudo systemctl start bluetooth.service
```

Check that service successfully started and is fine: 

```shell
    $ sudo systemctl status bluetooth.service
    ● bluetooth.service - Bluetooth service
     Loaded: loaded (/usr/lib/systemd/system/bluetooth.service; disabled; vendor preset: disabled)
     Active: active (running) since Thu 2020-02-20 19:35:07 CET; 23h ago
       Docs: man:bluetoothd(8)
   Main PID: 779 (bluetoothd)
      Tasks: 1 (limit: 6990)
     Memory: 2.7M
     CGroup: /system.slice/bluetooth.service
             └─779 /usr/lib/bluetooth/bluetoothd
```

reboot
check dmesg. should be similar

```shell
~ 
➔ dmesg | grep Bluetooth
[    5.493394] Bluetooth: Core ver 2.22
[    5.493415] Bluetooth: HCI device and connection manager initialized
[    5.493420] Bluetooth: HCI socket layer initialized
[    5.493422] Bluetooth: L2CAP socket layer initialized
[    5.493426] Bluetooth: SCO socket layer initialized
[    5.751843] Bluetooth: hci0: BCM: chip id 70
[    5.752829] Bluetooth: hci0: BCM: features 0x06
[    5.768841] Bluetooth: hci0: BCM43142A
[    5.769833] Bluetooth: hci0: BCM43142A0 (001.001.011) build 0000
[    6.489850] Bluetooth: hci0: BCM43142A0 (001.001.011) build 0215
[    6.505851] Bluetooth: hci0: Broadcom Bluetooth Device (43142)
```

#### Pairing with device

power up
try to connect with android phone
TODO try out with iPhone

run bluetoothctl

```shell
~ 
➔ sudo bluetoothctl
Agent registered
[CHG] Controller 80:56:F2:E5:43:E6 Pairable: yes
[bluetooth]# 
```

Power up built-in bluetooth module and run scanning

```shell
[bluetooth]# power on
Changing power on succeeded
[bluetooth]# scan on
Discovery started
[CHG] Controller 80:56:F2:E5:43:E6 Discovering: yes
[CHG] Device 78:BD:BC:D3:D5:68 RSSI: -92
[CHG] Device 78:BD:BC:D3:D5:68 Name: [TV] UE40J6272
[CHG] Device 78:BD:BC:D3:D5:68 Alias: [TV] UE40J6272
[CHG] Device 00:13:EF:00:03:04 RSSI: -59
```

Trust, Pair and connect to the HC-05

```shell
[bluetooth]# trust 00:13:EF:00:03:04
[CHG] Device 00:13:EF:00:03:04 Trusted: yes
Changing 00:13:EF:00:03:04 trust succeeded
[bluetooth]# pair 00:13:EF:00:03:04
Attempting to pair with 00:13:EF:00:03:04
Request PIN code
[agent] Enter PIN code: 1234
[CHG] Device 00:13:EF:00:03:04 UUIDs: 00001101-0000-1000-8000-00805f9b34fb
[CHG] Device 00:13:EF:00:03:04 ServicesResolved: yes
[CHG] Device 00:13:EF:00:03:04 Paired: yes
Pairing successful
[bluetooth]# set-alias mymodule
[CHG] Device 00:13:EF:00:03:04 Alias: mymodule
Changing mymodule succeeded
[bluetooth]# connect mymodule
Device mymodule not available
[CHG] Device 00:13:EF:00:03:04 ServicesResolved: no
[CHG] Device 00:13:EF:00:03:04 Connected: no
[CHG] Device 00:13:EF:00:03:04 Connected: yes
[mymodyle]# 
```

Disconnet

```shell
[mymodule]# disconnect
Attempting to disconnect from 00:13:EF:00:03:04
Successful disconnected
[CHG] Device 00:13:EF:00:03:04 Connected: no
[bluetooth]# 
```


#### Troubleshooting

Can't open RFCOMM control socket: Protocol not supported 
- No rfcomm module
https://duckduckgo.com/?t=ffab&q=Can%27t+open+RFCOMM+control+socket%3A+Protocol+not+supported&ia=web

Can't modprobe rfcomm
https://duckduckgo.com/?t=ffab&q=No+default+controller+available&ia=web

In case of other application occupied Bluetooth (startx ->connman occupies)
https://duckduckgo.com/?t=ffab&q=No+default+controller+available&ia=web

A lot of information
https://wiki.archlinux.org/index.php/Bluetooth

#### References

* [][1]
* [][6]
* [][4]
* [][5]
* [][3]

[1]: 
[2]: 
[3]: 
[4]: 
[5]: 
[6]: 
