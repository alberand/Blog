Title: Over the air updates for Arduino with Bluetooth
Date: 09.06.2019
Modified: 09.06.2019
Category: electronics, arduino
Status: draft
Authors: Andrey Albershtein
Summary: Over the air (wireless) updates of the Arduino firmware with Bluetooth
chip HC-05
lang: en

For one of my project I wanted to implement so called over the air (or shortly
OTA) updates of firmware. It means instead of using USB cable you use one of the
wireless technologies to upload your programs. In my case I used Bluetooth, in
particular cheap Chinese HC-05 chip.

The principle is quite simple. But first let's look at the booting process. 
When you power on your microcontroller it starts to execute application
stored in the internal memory. As uploading firmware with ISP is no so convenient people
wrote bootloader. 

The bootloader is simple application which is always stored in the memory. So,
when you power on your Arduino it actually start to execute bootloader. The
latter, in turn, monitor serial link (UART) if there are any incoming data or
commands. If so it starts to read it and write them directly into the memory.
This is what happens when you upload your sketch into the Arduino.

In the other case, if you don't want to upload anything bootloader see that
there is nothing on the UART and after some predefined timeout expires it stops.
However, it's not actually stop at all. It tells microcontroller where your
application is stored in the memory. The microcontroller in turn jumps to this
place and start executing the application.

To sum up, after power on microcontroller waits some time for something to
occur on the UART. If nothing comes it start executing application already
stored in the memory. If something occurs on the UART it start to overwrite
application stored in the memory with received data. Of course, there is a lot
more details.

There are some articles on how to use OTA on combination of Arduino and HC-05.
My realization requires pressing a reset button before uploading software. I
see it as a security features as to upload firmware to the device you need
physical access to it.

#### Introduction

The principle is following - Arduino is connected to the Bluetooth module. When
you want to update firmware you connect to the HC-05 from your PC. After
pressing reset bootloader waits for data on UART. Arduino IDE writes data to the
Bluetooth port. Bootloader reads it and saves to the memory.

The problem is that preprogrammed Arduino's bootloader is quite fast. I mean the
timeout for which it waits for the data is quite small. So, the first step will
be to modify bootloader.

Next we need configure Arduino and HC-05 module to correctly communicate between
each other. As it is standard serial link our modified bootloader should have
correct baud rate to communicate with the module.

#### Setup

My setup consist of Arduino Nano, HC-05 bluetooth module and I used Arduino Mega
2560. The latter is used for uploading bootloader and configuring bluetooth
module. 

Obviously, we need PC with Bluetooth to connect and program our device. The
basic schematic is shown in the following figure:

[](./image/ota_scheme.png)

#### Modifying bootloader

I decided to try one the popular bootloader with lot of useful features -
optiboot. As I discovered latter it already has implemented different timeouts.
So, one task is done. Next step is to understand the project compile it and
modify if necessary.

After tweaking around a lit bit I successfully compiled it for ATMega328p with
`make atmega328`. 

SPeed?

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



#### Test Bluetooth communication

#### Future

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
