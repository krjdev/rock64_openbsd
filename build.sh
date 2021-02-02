#!/bin/bash

#./scripts/toolchain.sh
source ./scripts/atf.sh
source ./scripts/u-boot.sh
#!/bin/bash

# File Name: build.sh
# Title    : BASH control script for building U-Boot for PINE64 ROCK64
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
SCRIPT_TOOLCHAIN="./scripts/toolchain.sh"
SCRIPT_ATF="./scripts/atf.sh"
SCRIPT_UBOOT="./scripts/u-boot.sh"

# Cleanup 
env_cleanup()
{
    unset SCRIPT_VERSION
    unset SCRIPT_TOOLCHAIN
    unset SCRIPT_ATF
    unset SCRIPT_UBOOT
}

show_usage()
{
    _SCRIPT=$(basename $0)
    echo "Usage: $_SCRIPT [OPTS]"
    echo
    echo "Description:"
    echo "This script builds U-Boot for PINE64 ROCK64"
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
    $SCRIPT_TOOLCHAIN --version
    $SCRIPT_ATF --version
    $SCRIPT_UBOOT --version
    unset _SCRIPT
}

build_all()
{
    source $SCRIPT_TOOLCHAIN
    source $SCRIPT_ATF
    source $SCRIPT_UBOOT
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

build_all
env_cleanup
exit 0
