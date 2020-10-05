# TUTORIAL: Install OpenBSD 6.7 on a PINE64 ROCK64 media board 

**Required hardware**

* PC with Linux (in this tutorial) or OpenBSD installed
* PINE64 ROCK64 media board (In this tutorial I use version 2.0 of the board)
* USB-UART-TTL converter (**Attention:** Use 3.3V only)

![alt text](https://github.com/krjdev/rock64_openbsd/blob/master/img/rock64-serial.png)

* microSD card

**Required software**

* UART Terminal (in this tutorial I use minicom)
* GCC cross compiler for ARM64 (aarch64)
* Image *miniroot67.fs* for ARM64 from the offical OpenBSD FTP mirrors

[Download (Mirror Austria)](https://ftp2.eu.openbsd.org/pub/OpenBSD/6.7/arm64/miniroot67.fs)

### Step 1 - Build ATF (ARM Trusted Firmware)


*NOTE*  
In this tutorial I usesd the offical GCC compiler from the ARM website.

* Checkout ATF sources  
``
$ git clone https://github.com/ARM-software/arm-trusted-firmware.git
``  
``
$ cd arm-trusted-firmware
``  
* Build ATF (BL31)  
``
$ make distclean
``  
``
$ make CROSS_COMPILE=/path/to/gcc/bin/aarch64-none-elf- PLAT=rk3328
``  
* Export ATF for U-Boot  
``
$ export BL31=/path/to/arm-trusted-firmware/build/rk3328/release/bl31/bl31.elf
``

*NOTE*  
The previous steps (build ATF) are required to successfully boot OpenBSD. Without these steps, U-Boot
will boot but cannot load OpenBSD.

### Step 2 - Build U-Boot


* Checkout U-Boot sources  
``
$ git clone https://github.com/u-boot/u-boot.git
``  
``
$ cd u-boot
``  
* Build U-Boot  
``
$ make mrproper
``  
``
$ make rock64-rk3328_defconfig
``  
``
$ make CROSS_COMPILE=/path/to/gcc/bin/aarch64-none-elf-
``

*NOTE*  
Alternatively you can use my prebuilt binaries:

[Rock64 (U-Boot v2020.07)](https://github.com/krjdev/rock64_openbsd/blob/master/bin/rock64/v2020.07)  
[RockPro64 (U-Boot v2020.07 - not tested)](https://github.com/krjdev/rock64_openbsd/blob/master/bin/rockpro64/v2020.07)  

![alt text](https://github.com/krjdev/rock64_openbsd/blob/master/img/rock64-u-boot_v2020.07.png)

[Rock64 (U-Boot v2020.10)](https://github.com/krjdev/rock64_openbsd/blob/master/bin/rock64/v2020.10)  

![alt text](https://github.com/krjdev/rock64_openbsd/blob/master/img/rock64-u-boot_v2020.10.png)

### Step 3 - Install *miniroot67.fs* on microSD card

* Connect the microSD card with your PC
* Open the terminal on your PC
* Copy *miniroot67.fs* to microSD

```
$ dd if=/path/to/miniroot67.fs of=/dev/sdx bs=1M
```

### Step 4 - Place *idbloader.img* and *u-boot.itb* on microSD card

* Place *idbloader.img* on microSD card
```
$ dd if=/path/to/idbloader.img of=/dev/sdx bs=512 seek=64 conv=sync
```
* Place *u-boot.itb* on microSD card
```
$ dd if=/path/to/u-boot.itb of=/dev/sdx bs=512 seek=16384 conv=sync
```

### Step 5 - Place *rk3328-rock64.dtb* on microSD card

* Mount the FAT partition  
``
$ mount -t vfat /dev/sdx1 /mnt
``  
* Create a directory with the name rockchip  
``
$ cd /mnt
``  
``
$ mkdir rockchip
``  
* Place the dtb file in this directory  
``
$ cp path/to/u-boot/arch/arm/dts/rk3328-rock64.dtb ./rockchip
``  
* Unmount the microSD card and remove the card

### Step 6 - Install OpenBSD

* Put microSD card in the ROCK64
* Start minicom with the baud rate 1500000
```
minicom -8 -D /dev/ttyUSB0 -b 1500000
```
* Power-On the ROCK64
* Wait until you see the OpenBSD Installer:

![alt text](https://github.com/krjdev/rock64_openbsd/blob/master/img/rock64-obsd_installer.png)

* Install OpenBSD: Follow the steps of the OpenBSD installer
* After successfull installation reboot OpenBSD

### Step 7 - Have fun with OpenBSD 6.7 on ROCK64!


![alt text](https://github.com/krjdev/rock64_openbsd/blob/master/img/rock64-obsd_welcome.png)

## Output (dmesg)

```
$ dmesg
OpenBSD 6.7 (GENERIC.MP) #602: Thu May  7 13:45:48 MDT 2020
    deraadt@arm64.openbsd.org:/usr/src/sys/arch/arm64/compile/GENERIC.MP
real mem  = 4211326976 (4016MB)
avail mem = 4007395328 (3821MB)
mainbus0 at root: Pine64 Rock64
cpu0 at mainbus0 mpidr 0: ARM Cortex-A53 r0p4
cpu0: 32KB 64b/line 2-way L1 VIPT I-cache, 32KB 64b/line 4-way L1 D-cache
cpu0: 256KB 64b/line 16-way L2 cache 
efi0 at mainbus0: UEFI 2.8
efi0: Das U-Boot rev 0x20200700
apm0 at mainbus0
psci0 at mainbus0: PSCI 1.1, SMCCC 1.2
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
dwge0 at mainbus0: address 0e:ef:78:b6:3b:f6   
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
cpu1 at mainbus0 mpidr 1: ARM Cortex-A53 r0p4
cpu1: 32KB 64b/line 2-way L1 VIPT I-cache, 32KB 64b/line 4-way L1 D-cache
cpu1: 256KB 64b/line 16-way L2 cache
cpu2 at mainbus0 mpidr 2: ARM Cortex-A53 r0p4
cpu2: 32KB 64b/line 2-way L1 VIPT I-cache, 32KB 64b/line 4-way L1 D-cache
cpu2: 256KB 64b/line 16-way L2 cache
cpu3 at mainbus0 mpidr 3: ARM Cortex-A53 r0p4
cpu3: 32KB 64b/line 2-way L1 VIPT I-cache, 32KB 64b/line 4-way L1 D-cache
cpu3: 256KB 64b/line 16-way L2 cache
usb1 at ohci0: USB revision 1.0
uhub1 at usb1 configuration 1 interface 0 "Generic OHCI root hub" rev 1.00/1.00 addr 1
scsibus0 at sdmmc0: 2 targets, initiator 0
sd0 at scsibus0 targ 1 lun 0: <SD/MMC, SC32G, 0080> removable
sd0: 30436MB, 512 bytes/sector, 62333952 sectors
sdmmc1: can't enable card
vscsi0 at root
scsibus1 at vscsi0: 256 targets
softraid0 at root
scsibus2 at softraid0: 256 targets
bootfile: sd0a:/bsd
boot device: sd0
root on sd0a (4f8a06bfda438700.a) swap on sd0b dump on sd0b
WARNING: bad clock chip time
WARNING: CHECK AND RESET THE DATE!
rkdrm0: no display interface ports configured
$
```

## Limitations

* HDMI output currently not working

## Credits:

Thanks to all people from U-Boot and the OpenBSD project.
