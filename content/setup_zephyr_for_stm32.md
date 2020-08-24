Title: Setup Zephyr OS for STM32 Nucleo
Date: 15.02.2020
Modified: 01.03.2020
Status: published
Tags: stm32, zephyr
Keywords: stm32, zephyr, tutorial, os, rtos
Author: Andrey Albershtein
Summary: Setting up and running Zephyr RTOS for STM32 Nucleo
Lang: en
Image: images/zephyr-logo.jpg

A few month ago I get a free STM32 Nucleo board from ST Microelectronics at
Nuremberg's [Embedded World][3]. I was thinking about buying one but didn't have any
excuse to do it. As I got one I started to look on one of the real-time OS
which catch my attention a long time ago - [Zephyr OS][1].

<div id="zephyr-logo-container" style="margin: -200px 0 0 -40%; width: 400px; position: absolute; z-index: -1; ">
    <img id="zephyr-logo" style="width:400px; opacity: 0.25;" alt="Zephyr RTOS" src="{static}/images/zephyr-logo.jpg">
</div>

After a first look it appeared to me as nicely design OS with rapidly growing
number of features. The other thing which I noticed is that the list of
supported boards is enormously big, it can come handy in the future. Moreover,
it is under intense development by the Intel corporation which means that it
won't die in a few years (I hope 😀).

In this note I will describe process of setting up development environment
for STM32 Nucleo (particularly for STM32L010RB) board with Zephyr OS. Later
I would like to add testing setup too.

[TOC]

## Environment setup

Firstly, install dependencies:

```console
$ sudo apt install --no-install-recommends git cmake ninja-build gperf \
    ccache dfu-util device-tree-compiler wget \
    python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
    make gcc gcc-multilib g++-multilib libsdl2-dev
```

<p class="note-right">
<span class="note-sign">Note:</span> Commonly used notation for shell commands is <code>$</code> - commands executed
by normal user and <code>#</code> commands executed as root
</p>

Then, install Zephyr's `west` tool. It is basically Python utility to help you
manage source codes and configuration of your repositories. To install it use
`pip` (Python's package manager):

```console
$ pip3 install --user west
$ echo 'export PATH=~/.local/bin:"$PATH"' >> ~/.bashrc
$ source ~/.bashrc
```

Now we can get zephyr source code (it will take sometime ~ 300 Mb):

```console
$ west init stm-testbed
```

Next update all submodules and install all the required python packages:

```console
$ cd stm-testbed
$ west update
$ pip3 install --user -r zephyr/scripts/requirements.txt
```

Lastly, we need to setup the zephyr-SDK (compilers and tools to build Zephyr).

```console
$ wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.11.1/zephyr-sdk-0.11.1-setup.run
$ sh zephyr-sdk-0.10.0-setup.run
```

The script will guide you through the installation process. The last thing to do
is to define two environment variables which will be later used by the Zephyr's
build system

```console
$ export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
$ export ZEPHYR_SDK_INSTALL_DIR=<sdk installation directory>
```

I also added them to my `~/.bashrc` to not export them every time. I forgot to
do it a few times and spend too much time looking for such a simple problem.

## Zephyr OS in QEMU simulation

Zephyr is ready for compilation. The developers thought about further
application development and testing so they added support of Qemu as default
build target. Therefore, if you have [Qemu][4] installed you can immediately
start to play with the system API.

Firstly, before building an application, we need to configure environment for
the Zephyr. Luckily, it is simple - just `source` the `zephyr-env.sh`
script:

```console
$ cd stm-testbed/zephyr
$ source zephyr-env.sh
```

Next, let's run provided `hello_world` application. Go to the following
directory and create `build` directory:

```console
$ cd samples/hello_world/
$ mkdir build && cd build
```

Now we will use `cmake` to prepare application for build (create `cmake` cache
file). As we want to run application in `Qemu` we need to tell `cmake` about it
with defining variable `BOARD` (with -D flag):

```console
$ cmake -GNinja -DBOARD=qemu_x86 ..
```

The `-GNunja` arguments tells `cmake` that later we will build our application
with [Ninja][5] building system. The last `..` is just path to the upper
directory.  Then, build and run it with `ninja`:

```console
$ ninja
$ ninja run
```

You should see something similar:

```text
SeaBIOS (version rel-1.12.0-0-ga698c8995f-prebuilt.qemu.org)
Booting from ROM..***** Booting Zephyr OS zephyr-v1.14.0-783-g021e27cfed46 *****
Hello World! qemu_x86
```

The last line is our application. Hurray!

<p class="note-left">
<span class="note-sign">Note: </span>To exit from Qemu press <code>CTRL + A</code> and then <code>X</code>
</p>

## Compiling and running "Hello World" example 

Now let's try it on the real hardware. Clean the build directory and
re-generate cmake cache for your STM32 board.

```console
$ ninja clean
$ cmake -GNinja -DBOARD=nucleo_l073rz ..
```

Connect your board to the PC and check that it appeard in the `/dev` directory
(mine is `/dev/ttyACM0`). Compile and flash application to the board:

```console
$ ninja
$ ninja flash
```

Run some serial monitor at `/dev/ttyACM0`, `115200 8N1` to check if firmware was
correctly uploaded. I use `minicom`:

```console
$ sudo minicom -s
```
    
Press reset button on the DevKit and you should see similar message:

```text
***** Booting Zephyr OS zephyr-v1.14.0-783-g021e27cfed46 *****
Hello World! nucleo_l073rz
```

## Creating application for Zephyr OS

In Zephyr world the build system is application-centric. That means that your
application is entry point in the build process. That, in turn, means that you
can control the way Zephyr OS is build from your application building process.

Zephyr is installed separately somewhere in the system. So, you use it as a
library. I suppose that they choose this way to simplify the process of
configuration management and building of the kernel.

As an examples let's create simple application based on blinky example. First of
all create working directory and `cmake`'s project file:

```console
$ mkdir app && cd app
$ mkdir src
$ touch CMakeLists.txt
```

Put the following configuration into the `CMakeList.txt`:

```cmake
# Boilerplate code, which pulls in the Zephyr build system.
cmake_minimum_required(VERSION 3.13.1)
include($ENV{ZEPHYR_BASE}/cmake/app/boilerplate.cmake NO_POLICY_SCOPE)
project(my_zephyr_app)

# Add your source file to the "app" target. This must come after
# the boilerplate code, which defines the target.
target_sources(app PRIVATE src/main.c)
```

Then copy source code of provided blinky example. Go back to the `zephyr`
folder and then take `samples/basic/blinky/src/main.c` and copy `main.c`.

Now connect your board and run `ninja flash`. It should compile and upload
application, built-in LED will start blinking.

<div class="wide-boi" >
    <img id="gifka" alt="Zephyr RTOS blinky app" src="{static}/images/stm32-zephyr.gif">
</div>

As you can see it is quite convenient to manage your application as it is
completely separate from source code of the OS. 

<script>
    switchToVertMobile = function () {
            console.log("switch to vert. mobile");
            document.getElementById("gifka").setAttribute("style", "width: 100%;")
            document.getElementById("zephyr-logo").style["opacity"] = "0.15";
            document.getElementById("zephyr-logo-container").style["margin-left"] = "-60%";
            document.getElementById("zephyr-logo-container").style["margin-top"] = "-75%";
            fancyNotes(false);
    };

    switchToHorMobile = function () {
            console.log("switch to hor. mobile");
            document.getElementById("gifka").setAttribute("style", "width: 80%;")
            document.getElementById("zephyr-logo").style["opacity"] = "0.25";
            document.getElementById("zephyr-logo-container").style["margin-left"] = "-30%";
            document.getElementById("zephyr-logo-container").style["margin-top"] = "-200px";
            fancyNotes(false);
    };

    switchToDesktop = function () {
            console.log("switch to desktop");
            document.getElementById("gifka").setAttribute("style", "")
            document.getElementById("zephyr-logo").style["opacity"] = "0.25";
            document.getElementById("zephyr-logo-container").style["margin-left"] = "-40%";
            document.getElementById("zephyr-logo-container").style["margin-top"] = "-200px";
            fancyNotes();
    };
</script>
<style>
.content h2 {
    text-shadow: 1px 1px 1px #fff;
}
.entry-content p {
    text-shadow: 1px 1px 1px #fff;
}
</style>

#### Update - Use official getting started

In the time when I started writing this article the official getting started was
a little bit hard to follow. However, now it is so concise and simple that I
would recommend to follow official [documentation][2].

#### References

* [Zephyr RTOS][1]
* [STM32 Nucleo (STM32L010RB)][6]
* [QEMU - processor emulator][4]
* [Ninja Build System][5]
* [Embedded World - Nuremberg, Germany][3]

[1]: https://www.zephyrproject.org/
[2]: https://docs.zephyrproject.org/latest/getting_started/index.html
[3]: https://www.embedded-world.de/en
[4]: https://www.qemu.org/
[5]: https://ninja-build.org/
[6]: https://www.st.com/en/evaluation-tools/nucleo-l010rb.html
