#!/bin/bash

# File Name: scripts/toolchain.sh
# Title    : BASH helper script for downloading GCC for AArch64
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
GCC_AARCH64_DIR="aarch64-none-elf"
GCC_AARCH64_VERSION="10.2-2020.11"
GCC_AARCH64="gcc-arm-$GCC_AARCH64_VERSION-x86_64-aarch64-none-elf"
GCC_AARCH64_TAR="$GCC_AARCH64.tar"
GCC_AARCH64_XZ="$GCC_AARCH64_TAR.xz"
GCC_AARCH64_ARM="https://developer.arm.com"
GCC_AARCH64_LINK="$GCC_AARCH64_ARM/-/media/Files/downloads/gnu-a/$GCC_AARCH64_VERSION/binrel/$GCC_AARCH64_XZ"

# Cleanup 
env_cleanup()
{
    unset SCRIPT_VERSION
    unset GCC_AARCH64_DIR
    unset GCC_AARCH64_VERSION
    unset GCC_AARCH64
    unset GCC_AARCH64_TAR
    unset GCC_AARCH64_XZ
    unset GCC_AARCH64_ARM
    unset GCC_AARCH64_LINK
}

show_usage()
{
    _SCRIPT=$(basename $0)
    echo "Usage: $_SCRIPT [OPTS]"
    echo
    echo "Description:"
    echo "This script downloads GCC for AArch64 for PINE64 ROCK64"
    echo
    echo "[OPTS]"
    echo "  -V, --version"
    echo "  Print script version and exit."
    echo "  -H, --help"
    echo "  Print this text and exit."
    unset _SCRIPT
}

show_version()
{
    _SCRIPT=$(basename $0)
    echo "$_SCRIPT: Version $SCRIPT_VERSION "
    unset _SCRIPT
}

download_toolchain()
{
    if [ ! -d "$GCC_AARCH64_DIR" ]
    then
        wget $GCC_AARCH64_LINK -O /tmp/$GCC_AARCH64_XZ
        tar -xf /tmp/$GCC_AARCH64_XZ
        mv $GCC_AARCH64 $GCC_AARCH64_DIR
    fi
}

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
    *)
        echo "Error unknown argument"
        env_cleanup
        exit 1
    esac
done

download_toolchain
env_cleanup
