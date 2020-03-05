Title: How to connect HC-05 module to Linux
Date: 21.02.2020
Modified: 21.02.2020
Status: draft
Tags: arduino, hc-05, bluetooth, linux
Keywords: arduino, hc-05, bluetooth, linux
Slug: hc-05-linux
Author: Andrey Albershtein
Summary: Configure and connect Bluetooth HC-05 module to Linux
Lang: en

In Linux, sometimes, even a seemingly simple task can end up to be quite hard to
solve. In this note I want to describe how to configure and connect [HC-05
Bluetooth module][1] to the Linux PC.

Play with these cheap (about `3$`) Bluetooth modules I wrote a small application
which can help to diagnose and configure them. In this article I use Arduino
Nano (atmega328p) and bare HC-05 without linear regulator. However, I create
custom PCB for easier access to the pins on the breadboard.

#### [`HCTOOLS`][3] - Arduino application

This application can be used on any Arduino starting from Arduino Nano. You can
download it on the [Github][3]. I used [platformio][2] as a development
environment so if you familiar with it you know what to do. If not you can use
classical Arduino IDE. To do so you need to:

1. Copy content of `src/main.cpp` into Arduino IDE
2. Install `SoftwareSerial` and `SimpleCLI` libraries with library manager
3. Upload the sketch.

The application provides "shell"-like interface to work with HC-05 module. It
has following commands/features:

* **echo** - Run simple echo server. It is useful to check if your module is
  working. You run this command, connect to the module with your phone or PC
  and start sending some text to it. The module will receive the text and
  send it back to you.
* **atmode** - This command will switch HC-05 module into AT command mode
  and then turn Arduino into serial passtrhogh device between your PC and
  HC-05. This will allow you to communicate with Bluetooth module without
  any additional hardware (with the exception of Arduino of course)
* **master** - configure connected HC-05 module as Bluetooth master.
* **slave** - configure connected HC-05 module as Bluetooth slave.
* **name** - change Bluetooth name of the module.
* **baudrate** - change baudrate of the module. This baudrate is used when
  module communicates with Arduino.

TODO Gif of the console? (those look nice)

To use it firstly you need to connect your Arduino and HC-05 module together.

**Hardware Setup**. The principle is that we actually need to control power to
the HC-05 module and pin 34 (or PIO11 or KEY). This way the application can
switch module between normal and AT command mode. That is actually everything
what we need 😀.

TODO: [Schematics][]

**Let's try it out!**. Connect Arduino and HC-05 as shown in the schematics
above and flash the application to the Arduino (with [platformio][2] or Arduino
IDE). Then open serial monitor and you should see something like this:

```text
HCTOOLS. Version: 1.0 (f0341d1)
# 
```

Type `help` to see all the available commands and their parameters.

#### Back to PC

Install Bluetooth stack

```shell
$ sudo apt-get install bluez bluez-utils
```

Check if `btusb` is loaded into the kernel:

```shell
$ lsmod | grep btusb
btusb                  65536  0
btrtl                  24576  1 btusb
btbcm                  16384  1 btusb
btintel                32768  1 btusb
bluetooth             675840  5 btrtl,btintel,btbcm,btusb
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
$ dmesg | grep Bluetooth
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
$ sudo bluetoothctl
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

* [HC-05 Bluetooth modules on Aliexpress (non-referal link)][1]
* [HCTOOLS application on Github][3]
* [][4]
* [][5]
* [][3]

[1]: https://www.aliexpress.com/wholesale?catId=0&SearchText=HC-05+Bluetooth
[2]: https://platformio.org/
[3]: https://github.com/alberand/hctools
[4]: 
[5]: 
[6]: 
