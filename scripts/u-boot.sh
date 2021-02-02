#!/bin/bash

# File Name: scripts/u-boot.sh
# Title    : BASH helper script for building U-Boot
# Project  : rock64_openbsd
# Author   : Copyright (C) 2021 Johannes Krottmayer <krjdev@gmail.com>
# Created  : 2021-02-02
# Modified : 2021-02-03
# Revised  : 
# Version  : 0.1.1.0
# License  : CC-BY (see file LICENSE.md)
#
# NOTE: This code is currently below version 1.0, and therefore is considered
# to be lacking in some functionality or documentation, or may not be fully
# tested. Nonetheless, you can expect most functions to work.

SCRIPT_VERSION="0.1.1.0"
GCC_AARCH64="aarch64-none-elf"
UBOOT_GIT="https://github.com/u-boot/u-boot.git"
UBOOT_DIR="u-boot"
UBOOT_VERSION="v2021.01"
UBOOT_ROCK64_CONFIG="rock64-rk3328_defconfig"
UBOOT_ROCK64_IDBLOADER="idbloader.img"
UBOOT_ROCK64_ITB="u-boot.itb"
UBOOT_ROCK64_DTB="rk3328-rock64.dtb"
UBOOT_SCRIPT_SRC="u-boot_usb.script"
UBOOT_SCRIPT_BIN="boot.scr"
UBOOT_SCRIPT_DESC="OpenBSD: USB-port"

# Flags
_SCRIPT_DEFAULT=0
_SCRIPT_KEEP=0
_UBOOT_VERSION=""

# Cleanup 
env_cleanup()
{
    unset SCRIPT_VERSION
    unset GCC_AARCH64
    unset UBOOT_GIT
    unset UBOOT_DIR
    unset UBOOT_VERSION
    unset UBOOT_ROCK64_CONFIG
    unset UBOOT_ROCK64_IDBLOADER
    unset UBOOT_ROCK64_ITB
    unset UBOOT_ROCK64_DTB
    unset UBOOT_SCRIPT_SRC
    unset UBOOT_SCRIPT_BIN
    unset UBOOT_SCRIPT_DESC
    unset _SCRIPT_DEFAULT
    unset _SCRIPT_KEEP
    unset _UBOOT_VERSION
}

show_usage()
{
    _SCRIPT=$(basename $0)
    echo "Usage: $_SCRIPT [OPTS]"
    echo "Usage: $_SCRIPT [OPTS] [ARGS...]"
    echo
    echo "Description:"
    echo "This script builds U-Boot for PINE64 ROCK64"
    echo
    echo "[OPTS]"
    echo "  -V, --version"
    echo "  Print script version and exit."
    echo "  -H, --help"
    echo "  Print this text and exit."
    echo "  -k, --keep"
    echo "  Don't remove the U-Boot source folder after successfull build."
    echo
    echo "[ARGS...]"
    echo "  <GIT_TAG>"
    echo "  Use this U-Boot version for building. There is currently no checking"
    echo "  if this version exists."
    unset _SCRIPT
}

show_version()
{
    _SCRIPT=$(basename $0)
    echo "$_SCRIPT: Version $SCRIPT_VERSION "
    unset _SCRIPT
}

set_uboot_version()
{
    _UBOOT_VERSION=$1
}

build_uboot()
{
    # Check if toolchains exists
    if [ ! -d "$PWD/$GCC_AARCH64" ]
    then
        echo "Error: Toolchains (GCC for AArch64) aren't present."
        env_cleanup
        exit 1
    fi
    
    # Check if ARM-Trusted-Firmware was build
    if [ -z "$BL31" ]
    then
        echo "Error: ARM-Trusted-Firmware is required to boot OpenBSD."
        env_cleanup
        exit 1
    fi
    
    if [ -d "$UBOOT_DIR" ]
    then
        cd $UBOOT_DIR
        git checkout master
        git pull origin master
    else
        git clone $UBOOT_GIT
        cd $UBOOT_DIR
    fi
    
    git checkout $_UBOOT_VERSION
    make mrproper
    make $UBOOT_ROCK64_CONFIG
    make CROSS_COMPILE=$PWD/../$GCC_AARCH64/bin/aarch64-none-elf-
    ./tools/mkimage -A arm64 -a 0 -e 0 -T script -C none -n "$UBOOT_SCRIPT_DESC" -d ../scripts/$UBOOT_SCRIPT_SRC $UBOOT_SCRIPT_BIN
    
    if [ ! -f "$UBOOT_ROCK64_IDBLOADER" ]
    then
        echo "Error: Build failed for $UBOOT_ROCK64_IDBLOADER."
        env_cleanup
        exit 1
    fi
    
    cp $UBOOT_ROCK64_IDBLOADER ../$UBOOT_ROCK64_IDBLOADER
    
    if [ ! -f "$UBOOT_ROCK64_ITB" ]
    then
        echo "Error: Build failed for $UBOOT_ROCK64_ITB"
        env_cleanup
        exit 1
    fi
    
    cp $UBOOT_ROCK64_ITB ../$UBOOT_ROCK64_ITB
    
    if [ ! -f "arch/arm/dts/$UBOOT_ROCK64_DTB" ]
    then
        echo "Error: Build failed for arch/arm/dts/$UBOOT_ROCK64_DTB"
        env_cleanup
        exit 1
    fi
    
    cp arch/arm/dts/$UBOOT_ROCK64_DTB ../$UBOOT_ROCK64_DTB
    
    if [ ! -f "$UBOOT_SCRIPT_BIN" ]
    then
        echo "Error: Build failed for $UBOOT_SCRIPT_BIN"
        env_cleanup
        exit 1
    fi
    
    cp $UBOOT_SCRIPT_BIN ../$UBOOT_SCRIPT_BIN
    cd ..
    
    if [ $_SCRIPT_KEEP -ne 1 ]
    then
        rm -Rf $UBOOT_DIR
    fi
}

_UBOOT_VERSION=$UBOOT_VERSION

if [ $# -eq 0 ]
then
    _SCRIPT_DEFAULT=1
else
    while [ $# -ne 0 ]
    do
        case $1 in
        -V|--version)
            show_version
            env_cleanup
            exit 1
            ;;
        -H|--help)
            show_usage
            env_cleanup
            exit 1
            ;;
        -k|--keep)
            _SCRIPT_KEEP=1
            shift
            ;;
        *)
            set_uboot_version $1
            shift
            
            if [ $# -ne 0 ]
            then
                echo "Error: Too many arguments"
                env_cleanup
                exit 1
            fi
            ;;
        esac
    done
fi

if [ $_SCRIPT_DEFAULT -eq 1 ]
then
    _UBOOT_VERSION=$UBOOT_VERSION
fi

build_uboot
env_cleanup
