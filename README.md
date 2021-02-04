# TUTORIAL: Install OpenBSD 6.8 on a PINE64 ROCK64 media board

**Required hardware**

* [PINE64 ROCK64 media board](https://www.pine64.org/devices/single-board-computers/rock64) (In this tutorial I use version **2.0** of the board)
* PC with a Linux distribution or OpenBSD  
  
**NOTE**  
  
In this tutorial I use the Linux distribution [openSUSE Leap 15.2](https://software.opensuse.org/distributions/leap). The additional BASH scripts (if you use them) for downloading the toolchains (GCC for AArch64), build ARM-Trusted-Firmware and U-Boot use default Linux commands. There are also some required software which is needed for a successfull build of U-Boot.  

* USB-UART-TTL converter  
  
**ATTENTION**  
  
Use **3.3V** logic level only, to avoid damages of the board

![alt text](https://github.com/krjdev/rock64_openbsd/blob/master/img/rock64-serial.png)

* microSD card

**Required software**

* UART Terminal (in this tutorial I use minicom)  
* GCC for the host system (required for U-Boot)  
* GCC cross compiler for ARM64 (AArch64)  
[Download: Toolchains from ARM](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-a/downloads)  
  
**NOTE**  
  
In this tutorial I use GCC for AArch64 ELF bare-metal targets (*aarch64-none-elf*).  
  
* Device Tree Compiler (required to build U-Boot)  
  
On *openSUSE*:  
```
$ sudo zypper install dtc
```  
On *Ubuntu*:  
```
$ sudo apt-get install device-tree-compiler
```
* SWIG (required to build U-Boot)  
  
On *openSUSE*:  
```
$ sudo zypper install swig
```  
On *Ubuntu*:  
```
$ sudo apt-get install swig
```
* Image *miniroot68.img* for ARM64 from the offical OpenBSD FTP mirrors  
[Download: Fastly (CDN)](https://cdn.openbsd.org/pub/OpenBSD/6.8/arm64/miniroot68.img)  
* U-Boot script for enabling one of the USB ports  
[Download](https://github.com/krjdev/rock64_openbsd/blob/master/scripts/u-boot_usb.script)  

### Step 0 - Preamble

You can skip [step 1](https://github.com/krjdev/rock64_openbsd#step-1---build-atf-arm-trusted-firmware) and  [step 2](https://github.com/krjdev/rock64_openbsd#step-2---build-u-boot), if you want to use my build scripts (initial version) for downloading the required toolchains, build ATF, build U-Boot and generate my U-Boot script for enabling the USB-port, or you can use my prebuilt binaries. If you choose these both ways you can begin at [step 3](https://github.com/krjdev/rock64_openbsd#step-3---install-miniroot68img-on-microsd-card).  

[Rock64 (U-Boot v2021.01)](https://github.com/krjdev/rock64_openbsd/blob/master/bin/rock64/U-Boot_v2021.01)  

![alt text](https://github.com/krjdev/rock64_openbsd/blob/master/img/rock64-u-boot_v2021.01.png)


To build U-Boot with my scripts:<img align="right" src="https://www.travis-ci.com/krjdev/rock64_openbsd.svg?branch=master">

```
$ git clone https://github.com/krjdev/rock64_openbsd.git
$ cd rock64_openbsd
$ sh build.sh
```

The required file(s) for this tutorial are placed in the root directory of the repository. The following files should be successfully created:  

* **bl31.elf**  

This file is the ARM-Trusted-Firmware. It is embedded in the U-Boot binaries. No longer required for this tutorial.  

* **boot.scr**  

This file ist the U-Boot script binary for enabling one of the USB ports. It's an inital release. Might change on further releases on this tutorial. The reason is, OpenBSD currently doesn't power-on the USB-ports. This script is a workaround as soon as the OpenBSD developers fix this isssue.  

* **idbloader.img**  

This is the second stage bootloader. The first stage bootloader is proprietary and resides in the embedded Flash in the used SoC (Rockchip RK3328).  

* **rk3328-rock64.dtb**  

The Device-Tree-Blob. It's the binary version of one or more Device-Tree sources. This file contains information, like embedded interfaces, about the SoC.  

* **u-boot.itb**  

This is the third stage bootloader. U-Boot itself.



### Step 1 - Build ATF (ARM Trusted Firmware)
* Checkout ATF sources  
```
$ git clone https://github.com/ARM-software/arm-trusted-firmware.git
$ cd arm-trusted-firmware
```
* Build ATF (BL31)  
```
$ make distclean
$ make CROSS_COMPILE=/path/to/gcc/bin/aarch64-none-elf- PLAT=rk3328
```
* Export ATF for U-Boot  
```
$ export BL31=/path/to/arm-trusted-firmware/build/rk3328/release/bl31/bl31.elf
```

**NOTE**  
The previous steps (build [ATF](https://github.com/krjdev/rock64_openbsd#step-1---build-atf-arm-trusted-firmware)) are required to successfully boot OpenBSD. Without these steps, U-Boot will boot but cannot load OpenBSD.

### Step 2 - Build U-Boot
* Checkout U-Boot sources  
```
$ git clone https://github.com/u-boot/u-boot.git
$ cd u-boot
```
* Build U-Boot  
```
$ make mrproper
$ make rock64-rk3328_defconfig
$ make CROSS_COMPILE=/path/to/gcc/bin/aarch64-none-elf-
```
* Compile U-Boot boot script (required for [step 7](https://github.com/krjdev/rock64_openbsd#step-7---enable-usb-port-for-openbsd))
```
$ ./tools/mkimage -A arm64 -a 0 -e 0 -T script -C none -n "Enable one USB-port" -d /path/to/u-boot_usb.script boot.scr
```

### Step 3 - Install *miniroot68.img* on microSD card

* Put the microSD card in your PC
* Open the terminal on your PC
* Copy **miniroot68.img** to microSD

```
$ sudo dd if=/path/to/miniroot68.img of=/dev/sdx bs=1M
```

### Step 4 - Place *idbloader.img* and *u-boot.itb* on microSD card

* Place **idbloader.img** on microSD card
```
$ sudo dd if=/path/to/idbloader.img of=/dev/sdx bs=512 seek=64 conv=sync
```
* Place **u-boot.itb** on microSD card
```
$ sudo dd if=/path/to/u-boot.itb of=/dev/sdx bs=512 seek=16384 conv=sync
```

### Step 5 - Install OpenBSD

* Put microSD card in the ROCK64
* Start minicom with the baud rate **1500000**
```
minicom -8 -D /dev/ttyUSB0 -b 1500000
```
* Power-On the ROCK64
* Wait until you see the OpenBSD Installer:

![alt text](https://github.com/krjdev/rock64_openbsd/blob/master/img/rock64-obsd68_installer.png)

* Install OpenBSD: Follow the steps of the OpenBSD installer
* After successfull installation shutdown OpenBSD

![alt text](https://github.com/krjdev/rock64_openbsd/blob/master/img/rock64-obsd68_success.png)

* Power-down the board and remove the microSD card from ROCK64

### Step 6 - Place *rk3328-rock64.dtb* on microSD card

* Put the microSD card in your PC
* Mount the FAT partition  
```
$ sudo mount -t vfat /dev/sdx1 /mnt
```
* Create a directory with the name rockchip  
```
$ cd /mnt
$ sudo mkdir rockchip
```
* Place the dtb file in this directory  
```
$ sudo cp path/to/u-boot/arch/arm/dts/rk3328-rock64.dtb rockchip
```

### Step 7 - Enable USB port for OpenBSD

* Change to root directory of the FAT partition
```
$ cd ..
```
* Copy **boot.scr** in this directory
```
$ sudo cp path/to/u-boot/boot.scr ./
```
* Umount microSD card
```
$ cd /
$ sudo umount /mnt
```
* Remove microSD card from your PC.

### Step 8 - Boot OpenBSD
* Put the microSD card in the ROCK64
* Power-on ROCK64

![alt text](https://github.com/krjdev/rock64_openbsd/blob/master/img/rock64-obsd68_login.png)

### Step 9 - Have fun with OpenBSD 6.8
#### Output (dmesg)
```
rock64# dmesg
OpenBSD 6.8 (GENERIC.MP) #828: Sun Oct  4 20:35:47 MDT 2020
    deraadt@arm64.openbsd.org:/usr/src/sys/arch/arm64/compile/GENERIC.MP
real mem  = 4209930240 (4014MB)
avail mem = 4003815424 (3818MB)
random: good seed from bootblocks
mainbus0 at root: Pine64 Rock64
psci0 at mainbus0: PSCI 1.1, SMCCC 1.2
cpu0 at mainbus0 mpidr 0: ARM Cortex-A53 r0p4
cpu0: 32KB 64b/line 2-way L1 VIPT I-cache, 32KB 64b/line 4-way L1 D-cache
cpu0: 256KB 64b/line 16-way L2 cache
cpu1 at mainbus0 mpidr 1: ARM Cortex-A53 r0p4
cpu1: 32KB 64b/line 2-way L1 VIPT I-cache, 32KB 64b/line 4-way L1 D-cache
cpu1: 256KB 64b/line 16-way L2 cache
cpu2 at mainbus0 mpidr 2: ARM Cortex-A53 r0p4
cpu2: 32KB 64b/line 2-way L1 VIPT I-cache, 32KB 64b/line 4-way L1 D-cache
cpu2: 256KB 64b/line 16-way L2 cache
cpu3 at mainbus0 mpidr 3: ARM Cortex-A53 r0p4
cpu3: 32KB 64b/line 2-way L1 VIPT I-cache, 32KB 64b/line 4-way L1 D-cache
cpu3: 256KB 64b/line 16-way L2 cache
efi0 at mainbus0: UEFI 2.8
efi0: Das U-Boot rev 0x20210100
apm0 at mainbus0
syscon0 at mainbus0: "syscon"
"io-domains" at syscon0 not configured
"grf-gpio" at syscon0 not configured
"power-controller" at syscon0 not configured
"reboot-mode" at syscon0 not configured
rkclock0 at mainbus0
syscon1 at mainbus0: "syscon"
"usb2-phy" at syscon1 not configured
ampintc0 at mainbus0 nirq 160, ncpu 4 ipi: 0, 1: "interrupt-controller"
rkpinctrl0 at mainbus0: "pinctrl"
rkgpio0 at rkpinctrl0
rkgpio1 at rkpinctrl0
rkgpio2 at rkpinctrl0
rkgpio3 at rkpinctrl0
"opp_table0" at mainbus0 not configured
simplebus0 at mainbus0: "bus"
"dmac" at simplebus0 not configured
"arm-pmu" at mainbus0 not configured
rkdrm0 at mainbus0
drm0 at rkdrm0
agtimer0 at mainbus0: tick rate 24000 KHz
"xin24m" at mainbus0 not configured
"i2s" at mainbus0 not configured
"spdif" at mainbus0 not configured
com0 at mainbus0: ns16550, no working fifo
com0: console
rkiic0 at mainbus0
iic0 at rkiic0
rkpmic0 at iic0 addr 0x18: RK805
"spi" at mainbus0 not configured
"watchdog" at mainbus0 not configured
rktemp0 at mainbus0
"efuse" at mainbus0 not configured
"gpu" at mainbus0 not configured
"video-codec" at mainbus0 not configured
"iommu" at mainbus0 not configured
"vop" at mainbus0 not configured
"iommu" at mainbus0 not configured
"hdmi" at mainbus0 not configured
"codec" at mainbus0 not configured
"phy" at mainbus0 not configured
dwmmc0 at mainbus0: 50 MHz base clock
sdmmc0 at dwmmc0: 4-bit, sd high-speed, mmc high-speed, dma
dwmmc1 at mainbus0: 50 MHz base clock
sdmmc1 at dwmmc1: 8-bit, mmc high-speed, dma
dwge0 at mainbus0: address 4e:41:b0:27:d6:24
rgephy0 at dwge0 phy 0: RTL8169S/8110S/8211 PHY, rev. 6
ehci0 at mainbus0
usb0 at ehci0: USB revision 2.0
uhub0 at usb0 configuration 1 interface 0 "Generic EHCI root hub" rev 2.00/1.00 addr 1
ohci0 at mainbus0: version 1.0
"usb" at mainbus0 not configured
"external-gmac-clock" at mainbus0 not configured
"sdmmc-regulator" at mainbus0 not configured
"vcc-host-5v-regulator" at mainbus0 not configured
"vcc-host1-5v-regulator" at mainbus0 not configured
"vcc-sys" at mainbus0 not configured
"ir-receiver" at mainbus0 not configured
"leds" at mainbus0 not configured
"sound" at mainbus0 not configured
"spdif-dit" at mainbus0 not configured
"dmc" at mainbus0 not configured
"usb" at mainbus0 not configured
"smbios" at mainbus0 not configured
usb1 at ohci0: USB revision 1.0
uhub1 at usb1 configuration 1 interface 0 "Generic OHCI root hub" rev 1.00/1.00 addr 1
scsibus0 at sdmmc0: 2 targets, initiator 0
sd0 at scsibus0 targ 1 lun 0: <SD/MMC, SC32G, 0080> removable
sd0: 30436MB, 512 bytes/sector, 62333952 sectors
scsibus1 at sdmmc1: 2 targets, initiator 0
sd1 at scsibus1 targ 1 lun 0: <SD/MMC, NCard, 0000> removable
sd1: 59000MB, 512 bytes/sector, 120832000 sectors
umass0 at uhub0 port 1 configuration 1 interface 0 "Kingston DT microDuo 3.0" rev 2.10/1.10 addr 2
umass0: using SCSI over Bulk-Only
scsibus2 at umass0: 2 targets, initiator 0
sd2 at scsibus2 targ 1 lun 0: <Kingston, DT microDuo 3.0, PMAP> removable serial.095116a3B031394FDE73
sd2: 29568MB, 512 bytes/sector, 60555264 sectors
vscsi0 at root
scsibus3 at vscsi0: 256 targets
softraid0 at root
scsibus4 at softraid0: 256 targets
bootfile: sd0a:/bsd
boot device: sd0
root on sd0a (d30a01e0ee125183.a) swap on sd0b dump on sd0b
WARNING: bad clock chip time
WARNING: CHECK AND RESET THE DATE!
rkdrm0: no display interface ports configured
rock64#
```

## Limitations
### HDMI
HDMI output currently not working.

### USB
Only one USB port is currently working [(step 7)](https://github.com/krjdev/rock64_openbsd#step-7---enable-usb-port-for-openbsd) with OpenBSD:

![alt text](https://github.com/krjdev/rock64_openbsd/blob/master/img/rock64-usb.png)

**NOTE**  
  
See [issue #5](https://github.com/krjdev/rock64_openbsd/issues/5) for additional information.

## Credits

Thanks to all people from [U-Boot](http://www.denx.de/wiki/U-Boot/WebHome) and the [OpenBSD project](https://www.openbsd.org/).

## License
 <p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/krjdev/rock64_openbsd">TUTORIAL: Install OpenBSD on a PINE64 ROCK64 media board</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://github.com/krjdev">Johannes Krottmayer</a> is licensed under <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY 4.0<br><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"></a></p>




