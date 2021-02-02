#!/bin/bash

git clone https://github.com/u-boot/u-boot.git
cd u-boot
git checkout v2021.01
make mrproper
make rock64-rk3328_defconfig
make CROSS_COMPILE=$PWD/../aarch64-none-elf/bin/aarch64-none-elf-
./tools/mkimage -A arm64 -a 0 -e 0 -T script -C none -n "Script: Enable USB power supply for OpenBSD" -d ../scripts/u-boot_usb.script boot.scr
cd ..
