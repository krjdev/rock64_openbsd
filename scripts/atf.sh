#!/bin/bash

git clone https://github.com/ARM-software/arm-trusted-firmware.git
cd arm-trusted-firmware
make distclean
make CROSS_COMPILE=$PWD/../aarch64-none-elf/bin/aarch64-none-elf- PLAT=rk3328
export BL31=$PWD/build/rk3328/release/bl31/bl31.elf
cd ..
