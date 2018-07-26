Title: PlatformIO + STM32 Nucleo
Date: 23.11.2017
Modified: 23.11.2017
Category: Electronics
Tags: stm32, platformio
Authors: Andrey Albershtein
Summary: Short instruction about setting up platformIO for work with STM32

- What is platformio and why it is udobno
- STM32 had a few paid IDE. But we can live without them
- Required software + hardware
- Platformio config
- Problem with libs
- Setup for Platformio IDE. I use vim add to .vimrc

In root directory of your project there is platformio configuration file
`platformio.ini`. We will need to create an environment in accordance with board
which we are using. Mine looks as follow:

```ini
[platformio]
env_default = nucleo

[env:nucleo]
platform = ststm32
framework = mbed
board = nucleo_l476rg
upload_protocol = stlink
lib_ldf_mode = deep
```

You can create a few environments for different board or different ways or
upload. I have only one configuration for STM32 Nucleo L476RG board. In main
`[platformio]` I set it as default to run `platformio` command without
additional parameters (`-e nucleo`).

In board configuration you need to set type of the platform as `ststm32`.
Because I am using `mbed` operation system I set framework to `mbed`. But you
can set it to {TODO}.

Next, you need to choose your board from the list of supproted hardware. This
list can be found by executing `platformio -{TODO}`.

Unfortunately, platformio library repository doesn't have many of the mbed
libraries. Therefore, most of them you will need to install manually by
downloading from `os.mbed.com` and moving to lib directory.

#### References: ####

- [platformIO]()
- [mbed]()
- [platformIO IDE]()
- []()


