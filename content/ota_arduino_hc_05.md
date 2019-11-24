Title: Over the air updates for Arduino with Bluetooth
Date: 09.06.2019
Modified: 09.06.2019
Status: draft
Authors: Andrey Albershtein
Summary: Over the air (wireless) updates of the Arduino firmware with Bluetooth chip HC-05
lang: en


For one of my project I wanted to implement so called over the air (or shortly
OTA) updates of firmware. It means instead of using USB cable you use one of the
wireless technologies to upload your programs. In my case I used Bluetooth, in
particular cheap Chinese HC-05 chip.

**Writing to memory**. The principle is quite simple. But first let's look at
the booting process.  When you power on your microcontroller it starts to
execute application stored in the internal flash memory. If we put our compiled
application into this memory it will be executed. The SPI interface is a how you
can rewrite this memory. However, it is not very convenient to use SPI every
time you want to upload new program. It would nice if we could use serial link
(UART) as it is simple and can be found almost everywhere.

**The bootloader**. It is simple application which is always stored in the
flash memory of microcontroller and being executed first. When you power on
your Arduino it actually start to execute bootloader. The latter, in turn,
monitor serial link (or possibly any other communication interface) if there are
any incoming data or commands. In the simplest case we sent a command which
tells bootloader to store any further incoming bytes into memory and start to
transmit our application. The communication protocol is actually much more
complicated [STK500][STK500].

**Serial link**. On most of the Arduinos there is USB to UART controller which
give us possibility to talk to the microcontroller via the USB port. But
basically we can connect our microcontroller to any serial interface. So, how we
can exploit it? The HC-05 is a small PCB module which can be used as Bluetooth
to USB controller. In other words on the one end there is PC/Phone with
Bluetooth and on the other end serial link connected to the MCU.

**My solution**. There are some articles about implementation of the over the
air updates based on combination of Arduino and HC-05. My realization don't need
any physical modification of the HC-05 and it requires pressing a reset button
before uploading new firmware. I see it as a security features (not a
restriction =)) as to upload firmware to the device you need physical access to
it.

#### Introduction

The principle is following - Arduino is connected to the Bluetooth module. When
you want to update firmware you connect to the HC-05 from your PC. After
pressing reset button bootloader waits for data on UART. Arduino IDE writes data
to the Bluetooth port. Bootloader reads it and saves to the memory.

**Timeout**. Normally, the bootloader don't wait infinitely long for the
commands from the PC. It has some timeout after which bootloader gave control
(runs) anything that is already in the memory. This timeout is quite short and
there comes a problem. The connection process of the HC-05 module and PC take
a few seconds 

The problem is that preprogrammed Arduino's bootloader is quite fast. I mean the
timeout for which it waits for the data is quite short. So, the first step will
be to modify bootloader.

Next we need configure Arduino and HC-05 module to correctly communicate between
each other. As it is standard serial link our modified bootloader should have
correct baud rate to communicate with the module.

#### Setup

My setup consist of Arduino Nano, HC-05 bluetooth module and I used Arduino Mega
2560. The latter is used for uploading bootloader into the Nano and configuring
Bluetooth module. 

[](./image/ota_scheme.png)

#### Modifying bootloader

I decided to try one the popular bootloader with lot of useful features -
optiboot. As I discovered latter it already has implemented different timeouts.
So, one task is done. Next step is to understand the project compile it and
modify if necessary.

After tweaking around a lit bit I successfully compiled it for ATMega328p with
`make atmega328`. 

The default baudrate set in the bootloader is `115200`. Therefore, our HC-05
should all talk on this rate.

#### Uploading new bootloader

The uploading process was a little bit tricky because all of my wires,
breadboards and Arduinos are from cheap Chinese manufactures their quality is
quite near to very bad. The main problem was contact between wires as they had
glue on the metallic end. So, if something doesn't work for you try to move
around with those wires - it can be a problem.

The first step to do is to take another Arduino and upload Arduion ISP sketch
from the standard set of examples. This application turns your Arduino into
programmer. 

The principle is following - the programming Arduino is connected to the PC. The
ISP interface of this Arduino connects to the ICSP (those six pin put aside) of
the Arduino we want to program.

It also use three digital pins to indicate programming 

#### Configuring HC-05 module

The module has two modes one in which we can use AT commands to configure it and
one for normal operation. We want the first one. First you need another Arduino
which will be middleware between PC and HC-05. I used Arduino MEGA 2560 as it
has three hardware UARTs and can simultaneously talk to two or more devices.
However, you can use any Arduino as there is library called <SoftwareSerial.h>
which allows you to create additional serial ports on most of the pins.

Most probably you will need to play a little bit with baud rate. In my module
default one is 38400 but I think I saw modules with 57600. So, configure your
communication in such a way that you have the same baud rate on both end of the
communication. Otherwise, it will be quite easy to get lost in all those
baudrates.

The following sequence of commands check version of the HC-05 module, switch
module to the slave mode and sets baudrate to `115200`/1 stop bin/no parity.

```
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

#### Test Bluetooth communication

#### Future Work

Updating firmware with overwriting the old one is a bad practice. If
communication is not reliable or device unexpectedly turns off your firmware
becomes unusable. The better way is to use external memory chip (or internal
memory if your application is small) and, firstly, write firmware at the
external memory and then copy and run it.

One of the bootloader which allows this is DualOptiboot. I am planning to try
this one in the next version of my Bluetooth controller. The first step will be
to choose some memory chip and add it to the board.

#### References
* [HC-05]()
* [Optiboot](https://github.com/Optiboot/optiboot)
* [DialOptiboot](https://github.com/LowPowerLab/DualOptiboot)
* [STK500](http://ww1.microchip.com/downloads/en/Appnotes/doc2591.pdf)
