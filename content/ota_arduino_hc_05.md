Title: Programming Arduino over Bluetooth
Date: 09.06.2019
Modified: 09.06.2019
Status: draft
Tags: arduino, bluetooth
Keywords: arduino, bluetooth, hc-05, ota, remotely, wireless, programming
Author: Andrey Albershtein
Summary: Over the air (wireless) programming of the Arduino with HC-05 Bluetooth module
lang: en

For one of my project I wanted to implement so called over the air (or shortly
OTA) updates of firmware over Bluetooth. That basically mean that you can
program Arduino remotely via Bluetooth HC-05 module.

## How bootloader works?

TODO: good info here: use it
I’ve used AVR microcontrollers both for hobbies and work projects. These
versatile microcontrollers ran the code I programmed them with, but once the
final device was shipped, it was hard to change the firmware (the software
running on the microcontroller): The user needed an ISP programmer and the
software tools to update the firmware. A more convenient solution is to use a
bootloader. The bootloader is a small program that runs in a separate memory
space on the microcontroller separated from the main application space. It can
accept firmware upgrades from various sources (USB is often used) and dump them
to the main application space. More complex implementations can do automated
upgrades via the Internet offering transparency to the end user.

**Internal memory**. All microcontrollers used in Arduino have internal flash
memory. This memory is used to store the code of an application and bootloader.
The important feature of ATMega MCU is that flash is "In-System
self-programmable". That means that MCU can updates its own memory without use
of external devices. As I said there is actually two application sitting in the
memory an application and bootloader.

**The bootloader**. It is simple application which is always stored in the
flash memory of microcontroller but could be rewritten as everything else. When
you power on your Arduino it doesn't immediately goes to your application, it
actually starts at specific address, so called **Reset vector**. This
address has "jump" instruction which tells it to jump to the address where
bootloader is located. You can actually get rid of bootloader and jump straight
to the application code but this approach has some major disadvantages.

<p class="note-right">
    <span class="note-sign">Note: </span> For example, one of the disadvantages
    is - that if your application will start updating itself and hang during the
    process. Or connection to the host will be lost. You will end up with
    non-working software which need to be updated with other tool.
</p>

The further action depends on the bootloader but, in most cases it configures
essential peripherals. Next, it starts waiting for the data on serial port. That
the moment when PC start sending bytes to the Arduino. Actually there is the
whole communication protocol - you could find specification in the official
specification [STK500][3]. The bootloader receives this data and writes it
to the memory. After communication is complete bootloader jumps to the
address where application is stored. From now on MCU starts executing received
code.

<div class="wide-boi" >
    <img id="gifka" alt="Bootloader process" data-action="zoom"
        src="{static}/images/bootloader-principle.png">
</div>

**Does it have to be serial/USB?**. On most of the Arduinos there is USB to UART
controller which give us possibility to talk to the microcontroller via USB
cable. But, basically, we can connect our microcontroller to any communication
interface. So, how we can exploit it? The HC-05 is Bluetooth module which
supports "Serial Port Profile". The modules emulates a serial cable but
wirelessly 😀. There are many more different one [Bluetooth profiles][4].

**The plan**. There are some articles on implementation of the "Over the
Air" updates based on combination of Arduino and HC-05. In this post I describe
realization which does not need any physical modification of the HC-05. However,
before uploading new firmware you are required to press a reset button. It can
be seen as a completely wrong as it much more convenient to have everything
automatic. But, it is super easy to setup and I see it as a security features
(not a restriction👌) as to upload firmware to the device you need physical
access to it so nobody else can do it.

## Over-the-air updates preparation

The setup is following - Arduino is connected to the Bluetooth module. To update
firmware you connects to the HC-05 from the PC. After pressing reset button
bootloader starts waiting for data on UART. Arduino IDE (or actually `avrdude`)
writes data to the Bluetooth port. Bootloader reads it and writes to the memory.

[][TODO image of setup]

**Timeout**. By default, bootloader doesn't wait indefinitely for the commands
from the PC. However, the timeout is quite short after which bootloader jumps
to anything that is already in the memory (application). That causes a little
problem as to create a connection between HC-05 module and PC takes a few
seconds.

So, the first step is to modify bootloader to force it to wait for a longer time
period. Next, we need to configure Arduino and HC-05 to correctly
communicate between each other. As it is normal serial link our modified
bootloader should have correct baud rate to communicate with the module.

### Needed hardware

[IMAGE OF HW][]

* Arduino Nano
* Arduino Nano
* HC-05 Bluetooth module
* Wires
* Breadoard

### Configuring Optiboot bootloader

I decided to try one of the popular bootloaders with lot of useful features -
[optiboot][1]. As I discovered later it already has implementation of different
timeouts. So, one task is done 🤔.

After tweaking around a little bit I successfully compiled it for ATMega328p
with `make atmega328`. Check out [official documentation][7] for more
information on how to compile for other board.

The default baudrate set in the bootloader is `115200`. I decide to leave it as
it is. But that means that I need to change baudrate on the HC-05 module as
default one is `38400`.

### Installing bootloader with Arduino Nano

The uploading process was a little bit tricky because all of my wires,
breadboards and Arduinos are from cheap Chinese manufactures 😐. The quality
is close to very bad. The main problem was loosely connection wires as they had
glue on the metallic tip. So, if communication is unstable try to move around
with those wires - it could be a reason why. Also, don't use the longest one.

**Arduino as ISP programmer**. The first step is to take another Arduino and
upload ArduionISP sketch from the standard set of examples. This application
turns your Arduino into a programmer (like you heh). 

<div class="wide-boi" >
    <img id="gifka" alt="Installing bootloader with Arduino Nano" 
        src="{static}/images/nano-update-bootloader.png">
</div>

The setup consist of two Arduino Nano and HC-05 bluetooth module. The second
Arduino is used as a programmer. You can also add some LEDs to a programmer to
see the state of uploading process.

The principle is following - the programming Arduino is connected to the PC.
Over the SPI this Arduino connects to the ICSP (those six pin put aside) of
the Arduino we want to program.

If you want you can also connect LEDs to pins x, x and x to see the state of the
programmer. I actually have one Arduino especially for programming the other
one. It has LEDs soldered straight to the pins:

[IMAGE of arduino nano with leds][]

### How to change HC-05 configuration

The module has two modes - one for normal operation and one for changing
configuration with AT commands. Firstly, you need serial adapter to send
commands to the module from the PC. 

If you have USB to serial adapter (something like [this][8]) I would suggest to
use it. But you can replace it with another Arduino with serial passthrough 
application.

<p class="note-left">
    <span class="note-sign">Note: </span> By serial passthrough application I
    mean the app which reads data on one serial port and send it to another one
    and vise versa.
</p>

<div class="wide-boi" >
    <img id="gifka" alt="Image of setup to change configuration in HC-05" 
        src="{static}/images/hc-05-configuration.png">
</div>

The Arduino is connected to the PC with a cable. I used Arduino Nano which has
only one serial port. Therefore, my only port is occupied by a PC. But we need a
second one for the HC-05. The solution is amazing <SoftwareSerial.h> library
which allows you to configure some pins to behave as a serial port. Upload
following sketch into your board:

```cpp
#include <SoftwareSerial.h>

#define BAUDRATE 38400

SoftwareSerial hcmodule(10, 11); // RX, TX

void setup()
{
  Serial.begin(BAUDRATE);
  while (!Serial) { ; }

  Serial.println("Serial passthrough");

  hcmodule.begin(BAUDRATE);
}

void loop()
{
  if (hcmodule.available())
    Serial.write(hcmodule.read());
  if (Serial.available())
    hcmodule.write(Serial.read());
}
```

Possibly, you will need to play a little bit with baud rate. My module had
default one `38400` but I think I saw modules with `57600`. So, try both✌️..

[connection of HC-05 with pin 34 to high][]

Connect HC-05 module as shown in the figure above. Then, turn off and turn on
module by disconnecting power wire. As pin 34 is high HC-05 will boots into AT
mode.

Open serial monitor on your PC. The following sequence of commands checks
version of the HC-05 module, switches module to the slave mode and sets baudrate
to `115200` with 1 stop bin and no parity.

```console
AT
> OK
AT+VERSION?
> +VERSION:2.0-20100601
AT+ROLE=0
> OK
AT+UART:115200,1,0
> OK
AT+UART?
> +UART:115200,1,0
> OK
```

You can also change name with `AT+NAME=name`. I created a [small application][9]
which could be easier to use if you want to configure multiple devices.

## Uploading firmware over Bluetooth

On Windows HC-05 should be visible as `COMx` port. So, you could choose it
directly in the Arduino IDE. On Linux there is a little bit more steps to
connect the module. I wrote [the whole article][10] on that topic 🤨.

### Testing Bluetooth communication

Let's test that communication works at all before we try to update firmware.
Upload the same serial pass through firmware but with correct baudrate, as I
mentioned I used `115200`.

Then, run one serial monitor on port with Arduino (e.g. `COM1` or 🐧
`/dev/ttyUSB0`). The second one on virtual port attached to Bluetooth channel
(e.g. `COM2` or 🐧 `/dev/rfcomm0`).

### Wireless programming

So, now uploading process is following:

1. Compile application
2. Run `avrdude` on serial port attached to the Bluetooth channel
3. Press reset on the Arduino

It works well in both Arduino IDE and platformio. However, sometimes `avrdude`
can't synchronise with the bootloader and start printing errors. Just reset it
one more time and it will catch up.

## Future Improvements

Updating firmware with overwriting the old one is a bad practice. If
communication is not reliable or device unexpectedly turns off your firmware
becomes unusable. The better way is to use external memory chip (or internal
memory if your application is small) and, firstly, write firmware at the
external memory and then copy and run it.

One of the bootloader which allows this is DualOptiboot. I am planning to try
this one in the next version of my Bluetooth controller. The first step will be
to choose some memory chip and add it to the board.

### References
* [HC-05][6]
* [Optiboot][1]
* [DualOptiboot][2]
* [STK500 protocol][3]
* [List of Bluetooth profiles][4]
* [ATmega328P datasheet][5]
* [Good FAQ about Bootloaders by Brad Schick][11]

[1]: https://github.com/Optiboot/optiboot
[2]: https://github.com/LowPowerLab/DualOptiboot
[3]: http://ww1.microchip.com/downloads/en/Appnotes/doc2591.pdf
[4]: https://en.wikipedia.org/wiki/List_of_Bluetooth_profiles
[5]: http://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-7810-Automotive-Microcontrollers-ATmega328P_Datasheet.pdf
[6]: https://www.aliexpress.com/wholesale?catId=0&SearchText=hc-05
[7]: https://github.com/Optiboot/optiboot/wiki/CompilingOptiboot
[8]: https://www.aliexpress.com/item/32826575637.html?spm=a2g0o.productlist.0.0.1a1b152byezyN0&algo_pvid=1415518c-b43a-43ee-bc72-99da975e1540&algo_expid=1415518c-b43a-43ee-bc72-99da975e1540-0&btsid=0be3764315876534842897724efca8&ws_ab_test=searchweb0_0,searchweb201602_,searchweb201603_
[9]: https://github.com/alberand/hctools
[10]: https://alberand.com/hc-05-linux.html
[11]: https://www.avrfreaks.net/sites/default/files/bootloader_faq.pdf
