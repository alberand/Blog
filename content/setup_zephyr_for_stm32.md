Title: Setup Zephyr OS for STM32 Nucleo
Date: 28.05.2019
Modified: 28.05.2019
Status: published
Tags: stm32, zephyr
Authors: Andrey Albershtein
Summary: Setting up and running Zephyr RTOS for STM32 Nucleo
lang: en

A few month ago I get a free STM32 Nucleo board from ST Microelectronics at
Nuremberg's Embedded World. I was thinking about buying one but didn't have any
excuse to do it. As I got one I wanted to try one of the real-time OS which
catch my attention - [Zephyr OS][1].

After a first look it appeared to me as very nicely design OS with rapidly
growing number of features and more importantly number of supported boards
constantly grows. Moreover, as I noticed it is under intense development with
support of Intel corporation which can a bad and in the same time a good thing.

In this article I will describe process of setting up development environment
for STM32 Nucleo platform. (Later I would like to add testing setup too)

#### Environment setup

Firstly, lets install Zephyr's `west` tool. This is basically Python tool to
help you manage source codes and configuration of your repositories. To install
it use `pip` (Python's package manager):

    pip3 install --user west

Now we can get zephyr source code:

    west init stm-testbed

Next install all the required python packages:

    cd stm-testbed
    pip3 install --user -r zephyr/scripts/requirements.txt

Lastly, we need to setup the zephyr-SDK (compilers and tools to build Zephyr).

    wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.10.0/zephyr-sdk-0.10.0-setup.run
    sh zephyr-sdk-0.10.0-setup.run

The script will lead you through the installation process. The last thing to do
is to define two environment variables which will be later used by the Zephyr's
build system

    export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
    export ZEPHYR_SDK_INSTALL_DIR=<sdk installation directory>

I also added them to my `~/.bashrc` to not add them every time. I forgot about
them a few time and spend too much time looking for such simple problem.

#### Soft simulation

Zephyr is ready for compilation. The developers thought about further
application development and testing so they added support of Qemu as default
platform. Therefore, if you have Qemu installed you can immediately start to
play with the system API.

Firstly, before building an application, we need to configure environment for
the Zephyr. Luckily, it is simple. To do this just `source` the `zephyr-env.sh`
script:

    cd zephyr
    source zephyr-env.sh

Next let's run provided `hello_world` application. Go to the following
directory and create `build` directory:

    cd zephyr/samples/hello_world/
    mkdir build && cd build

Now we will use `cmake` to prepare application for build (create cmake cache).
As we want to run application in Qemu we need to tell cmake about it with
defining variable `BOARD` (with -D flag):

    cmake -GNinja -DBOARD=qemu_x86 ..

The `-GNunja` arguments tells `cmake` that later we will build our application
with Ninja building system. The last `..` is just path to the upper directory.
Then, build and run it with `ninja`:

    ninja
    ninja run

You should see something similar:

    SeaBIOS (version rel-1.12.0-0-ga698c8995f-prebuilt.qemu.org)
    Booting from ROM..***** Booting Zephyr OS zephyr-v1.14.0-783-g021e27cfed46 *****
    Hello World! qemu_x86

The last line is our application. Hurray!

**Note:** To exit from Qemu press `CTRL + A` and then `X`

#### Compiling and running example 

Now let's try it on the real hardware. Clean the build directory and
re-generate cmake cache for your STM32 board.

    ninja clean
    cmake -GNinja -DBOARD=nucleo_l073rz ..

Connect your board to the PC and check that it appeard in the `/dev` directory
(mine is `/dev/ttyACM0`). Compile and flash application to the board:

    ninja
    ninja flash

Run some serial monitor at `/dev/ttyACM0`, `115200 8N1` to check if firmware was
correctly uploaded. I use `minicom`:

    sudo minicom -s
    
Press reset button on the DevKit and you should see similar message:

    ***** Booting Zephyr OS zephyr-v1.14.0-783-g021e27cfed46 *****
    Hello World! nucleo_l073rz

#### Creating custom application

#### Future improvements

* testing

#### References

* [Zephur RTOS](https://www.zephyrproject.org/)
* [STM32 Nucleo (STM32L010RB)](https://www.st.com/en/evaluation-tools/nucleo-l010rb.html)
* [QEMU - processor emulator](https://www.qemu.org/)
* [Ninja Build System](https://ninja-build.org/)
* [Embedded World - Nuremberg, Germany](https://www.embedded-world.de/en)

[1]: https://www.zephyrproject.org/
