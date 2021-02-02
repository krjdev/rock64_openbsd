#!/bin/bash

# File Name: scripts/atf.sh
# Title    : BASH helper script for building ARM-Trusted-Firmware
# Project  : rock64_openbsd
# Author   : Copyright (C) 2021 Johannes Krottmayer <krjdev@gmail.com>
# Created  : 2021-02-02
# Modified : 
# Revised  : 
# Version  : 0.1.0.0
# License  : CC-BY (see file LICENSE.md)
#
# NOTE: This code is currently below version 1.0, and therefore is considered
# to be lacking in some functionality or documentation, or may not be fully
# tested. Nonetheless, you can expect most functions to work.

SCRIPT_VERSION="0.1.0.0"
GCC_AARCH64="aarch64-none-elf"
ATF_GIT="https://github.com/ARM-software/arm-trusted-firmware.git"
ATF_DIR="arm-trusted-firmware"
ATF_VERSION="v2.4"
ATF_ROCK64_CONFIG="rk3328"
ATF_BL31="bl31.elf"

# Flags
_SCRIPT_DEFAULT=0
_SCRIPT_KEEP=0
_ATF_VERSION=""

# Cleanup 
env_cleanup()
{
    unset SCRIPT_VERSION
    unset GCC_AARCH64
    unset ATF_GIT
    unset ATF_DIR
    unset ATF_VERSION
    unset ATF_ROCK64_CONFIG
    unset ATF_BL31
    unset _SCRIPT_DEFAULT
    unset _SCRIPT_KEEP
    unset _ATF_VERSION
}

show_usage()
{
    _SCRIPT=$(basename $0)
    echo "Usage: $_SCRIPT [OPTS]"
    echo "Usage: $_SCRIPT [OPTS] [ARGS...]"
    echo
    echo "Description:"
    echo "This script builds ARM-Trusted-Firmware for PINE64 ROCK64"
    echo
    echo "[OPTS]"
    echo "  -V, --version"
    echo "  Print script version and exit."
    echo "  -H, --help"
    echo "  Print this text and exit."
    echo "  -k, --keep"
    echo "  Don't remove the ATF source folder after successfull build."
    echo
    echo "[ARGS...]"
    echo "  <GIT_TAG>"
    echo "  Use this ATF version for building. There is currently no checking"
    echo "  if this version exists."
    unset _SCRIPT
}

show_version()
{
    _SCRIPT=$(basename $0)
    echo "$_SCRIPT: Version $SCRIPT_VERSION "
    unset _SCRIPT
}

set_atf_version()
{
    _ATF_VERSION=$1
}

build_atf()
{
    # Check if toolchains exists
    if [ ! -d "$PWD/$GCC_AARCH64" ]
    then
        echo "Error: Toolchains (GCC for AArch64) aren't present."
        env_cleanup
        exit 1
    fi
    
    if [ -d "$ATF_DIR" ]
    then
        cd $ATF_DIR
        git checkout master
        git pull origin master
    else
        git clone $ATF_GIT
        cd $ATF_DIR
    fi
    
    git checkout $_ATF_VERSION
    make distclean
    make CROSS_COMPILE=$PWD/../$GCC_AARCH64/bin/aarch64-none-elf- PLAT=$ATF_ROCK64_CONFIG
    cp "build/$ATF_ROCK64_CONFIG/release/bl31/$ATF_BL31" ../$ATF_BL31
    cd ..
    export BL31="$PWD/$ATF_BL31"
    
    if [ $_SCRIPT_KEEP -ne 1 ]
    then
        rm -Rf $ATF_DIR
    fi
}

_ATF_VERSION=$ATF_VERSION

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
            set_atf_version $1
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
    _ATF_VERSION=$ATF_VERSION
fi

build_atf
env_cleanup
exit 0
