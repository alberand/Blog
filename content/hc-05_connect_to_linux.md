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

In Linux even a initially simple task could end up being such a big headache
especially when it Bluetooth. In this note I want to describe how to configure
and connect [HC-05 Bluetooth module][1] to the Linux PC.

Playing with these cheap (about `3$`) Bluetooth modules I wrote a small
application which can help to diagnose and configure them. In this article I use
Arduino Nano (atmega328p) and bare HC-05 without linear power regulator. I think
that you won't need solder anything as we will need only TX, RX and KEY pins of
the HC-05.

<div style="text-align: center;">
    <img class="image" alt="HC-05 Bluetooth module" style="max-width: 700px; max-height: 400px;" src="{static}/images/hc-05.jpg">
    <p class="picture-legend">
        Image is taken from 
        <a alt="Arduino e-shop" href="https://www.laskarduino.cz/bluetooth-modul-hc-05-ttl/">www.laskarduino.cz</a>
    </p>
</div>

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

To use it firstly you need to connect your Arduino and HC-05 module together.

**Hardware Setup**. The principle is that we actually need to control power to
the HC-05 module and pin 34 (or PIO11 or KEY). This way the application can
switch module between normal and AT command mode. That is actually everything
what we need 😀.

<div style="text-align: center;">
    <img id="schematics" class="image" alt="Schematics of connection of HC-05 Bluetooth module and Arduino" style="max-height: 400px;" src="{static}/images/008-schematics.png">
</div>

**Let's try it out!**. Connect Arduino and HC-05 as shown in the schematics
above and flash the application to the Arduino (with [platformio][2] or Arduino
IDE). Then open serial monitor and you should see something like this:

```text
HCTOOLS. Version: 1.0 (f0341d1)
# 
```

Type `help` to see all the available commands and their parameters.

#### Back to PC

Install Bluetooth stack:

```shell
$ sudo apt-get install bluez bluez-utils
```

Now, lets check if kernel module is installed and loaded. For some chips it will
be enough to have `btusb` loaded but for other chips (like mine Broadcom chip)
you will need to find and install appropriate driver. You can check if `btusb`
is loaded into the kernel by the following command:

```shell
$ lsmod | grep btusb
btusb                  65536  0
btrtl                  24576  1 btusb
btbcm                  16384  1 btusb
btintel                32768  1 btusb
bluetooth             675840  5 btrtl,btintel,btbcm,btusb
```

If there is nothing in the output you should try to install general Bluetooth
driver:

```shell
$ sudo apt-get install btusb
```

If it won't work try to find driver for your particular device. You can find out
some information about name of your Bluetooth chip with following commands:

```shell
$ lsusb | grep Bluetooth
... output is hidden ...
$ dmesg | grep Bluetooth
... output is hidden ...
```

<p class="note-right">
<span class="note-sign">Note:</span> 
In case you also have <code>Broadcom</code> chip I would recommend to look into
this <a href="https://askubuntu.com/questions/632336/bluetooth-broadcom-43142-isnt-working/632348#632348">instruction</a>. It seems to be a common solution.
</p>

After driver is installed and kernel modules is loaded start and enable
Bluetooth service:

```shell
$ sudo systemctl enable bluetooth.service
$ sudo systemctl start bluetooth.service
```

Check that service successfully started:

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

Now, if you installed your driver reset your PC/laptop. It should not be reboot
but power reset (power off -> power on) because during reboot your drivers could
be still stay unloaded. After boot check output of `dmesg` it should be
something similar to this:

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

First of all, I always try to connect to the HC-05 with Android phone. It always
a good sign if everything going well. So, in case you have one try that. Anyway,
in the linux run `bluetoothctl`:

```shell
$ sudo bluetoothctl
Agent registered
[CHG] Controller 80:56:F2:E5:43:E6 Pairable: yes
[bluetooth]# 
```

Make power reset of the board build before and turn on scanning on your PC:

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

After something like HC-05 will appear on the screen you will need to make it
trustworthy, pair it with your PC and try to connect to it. That can be done by
the following commands `trust <MAC>`, `pair <MAC>` and `connect <MAC>`
accordingly.

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

If you'd like to check if disconnect works:

```shell
[mymodule]# disconnect
Attempting to disconnect from 00:13:EF:00:03:04
Successful disconnected
[CHG] Device 00:13:EF:00:03:04 Connected: no
[bluetooth]# 
```

#### Time to open serial monitor

The last step is to create serial port. The following command binds your
Bluetooth device with rfcomm (`/dev/rmcomm0` in this case) device. It won't
immediately connect to your HC-05 only when an application such as serial
monitor will open it. More about [RFCOMM protocol and devices][6].

Unfortunately, on some systems (e.g. arch linux) `rfcomm` utility can be
deprecated and won't be available in the official repository. Try to find
instruction of how to install it on your particular system (See [Arch Wiki][9]). 

```shell
    $ sudo rfcomm bind rfcomm0 <MAC-OF-HC-05>
```

Now you should have serial port `/dev/rmcomm0` which is attached to your
Bluetooth device. 

Let's test that it works. In another terminal open serial monitor attached to
Arduino with `HCTOOLS` application and run `echo` command:

```shell
    $ pio -e nano -t monitor
    ...long output is hidden...
    Looking for advanced Serial Monitor with UI? Check
    http://bit.ly/pio-advanced-monitor                     with IPv6
    --- Miniterm on /dev/ttyUSB0  115200,8,N,1 ---
    --- Quit: Ctrl+C | Menu: Ctrl+T | Help: Ctrl+T followed by Ctrl+H ---
    HCTOOLS. Version: 1.0
    # echo
    Echoing every received character. CTRL-D to stop it.
```

Try to open serial monitor on this port and communicate with device:

```shell
    $ pio device monitor -p /dev/rfcomm0 -b 115200
    ...long output is hidden...
    --- Miniterm on /dev/ttyUSB0  115200,8,N,1 ---
    --- Quit: Ctrl+C | Menu: Ctrl+T | Help: Ctrl+T followed by Ctrl+H ---
    Hello
```

Now, if you send something to Arduino it will send it to HC-05 and then to your
`/dev/rfcomm0` port. If you will send something to the `/dev/rfcomm0` with a
newline it will send it back to you.

<div style="text-align: center;">
    <img class="image" alt="HC-05 Bluetooth module" style="max-width: 700px; max-height: 400px;" src="{static}/images/008-hc-05-overall.png">
</div>

#### Troubleshooting

There is list of problems which I faced during my attempts to configure
everything right.

1. The following messages in response to  `rfcomm bind` command probably means
   that you don't have kernel module for RFCOMM protocol. Try to load it `sudo
   modprobe rfcomm`. Also try to update the kernel.

    ```
        Can't open RFCOMM control socket: Protocol not supported 
    ```

2. If `bluetoothctl` show `No default controller available` make sure that you
   have your driver installed and then run `bluetoothctl` with `sudo`
   ([stackoverflow answer][7]).

3. It can happen that other application is using Bluetooth and by doing so it
   will occupy Bluetooth controller (in my case it was `connman`). You can
   unblock it by running flowing command:

        $ sudo rfkill list
        0: tpacpi_bluetooth_sw: Bluetooth
            Soft blocked: no
            Hard blocked: no
        1: hci0: Bluetooth
            Soft blocked: yes
            Hard blocked: no
        5: phy3: Wireless LAN
            Soft blocked: no
            Hard blocked: no
        $ sudo rfkill unblock all
        $ sudo rfkill list
        ...
        1: hci0: Bluetooth
            Soft blocked: no
            Hard blocked: no
        ...

4. As always power on/off help in a few cases 😀.
5. A lot of information about Bluetooth is available on the [Arch Linux Wiki][8]

#### References

* [HC-05 Bluetooth modules on Aliexpress (non-referal link)][1]
* [HCTOOLS application on Github][3]
* [How to fix Bluetooth with Broadcom chip][4]
* [Arch Linux Wiki - Bluetooth][5]
* [RFCOMM Protocol][6]

[1]: https://www.aliexpress.com/wholesale?catId=0&SearchText=HC-05+Bluetooth
[2]: https://platformio.org/
[3]: https://github.com/alberand/hctools
[4]: https://askubuntu.com/questions/632336/bluetooth-broadcom-43142-isnt-working/632348#632348 
[5]: https://wiki.archlinux.org/index.php/Bluetooth
[6]: https://www.amd.e-technik.uni-rostock.de/ma/gol/lectures/wirlec/bluetooth_info/rfcomm.html#Device%20Types
[7]: https://stackoverflow.com/questions/48279646/bluetoothctl-no-default-controller-available
[8]: https://wiki.archlinux.org/index.php/Bluetooth
[9]: https://wiki.archlinux.org/index.php/bluetooth#Deprecated_BlueZ_tools

<script>
 margin: ;
    switchToVertMobile = function () {
            document.getElementById("schematics").style["margin"] = "30px 0";
            document.getElementById("schematics").style["padding"] = "0 20px";
    };

    switchToHorMobile = function () {
            document.getElementById("schematics").style["margin"] = "30px 0";
            document.getElementById("schematics").style["padding"] = "0 20px";
    };

    switchToDesktop = function () {
            document.getElementById("schematics").style["margin"] = "30px 0 30px -40px";
            document.getElementById("schematics").style["padding"] = "0";
    };
</script>
