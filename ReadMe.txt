=======================================================================
This is the imx linux mfgtool for imx6UL

The NXP has mfgtoolcli, but not working at all in my Ubuntu 14.04/16.04.
Even I tried to build from scartch.

And this repo contains the scrips to flash the Nand Flash in iMX6UL board.

=======================================================================
How to use
0. setup dir
    $ git clone https://github.com/tonyho/imx6ul_linux_mfgtools.git ~/imx6ul_linux_mfgtools
1. Clone and build the imx_usb_loader and the utp
1.1 imx_usb_loader: 
    !!!notice the checkout version, the head is not working!!!!

    $ git clone https://github.com/boundarydevices/imx_usb_loader.git imx_usb_loader_imx6ul
    $ cd imx_usb_loader_imx6ul
    $ git checkout 48a85c0b84611c089cf870638fd1241619324b1d -b local

    $make

1.2 utp
    $ cd ~/imx6ul_linux_mfgtools
    $ git clone https://github.com/ixonos/utp_com.git
    $ cd utp_com
    $ make
    $ cd ~/imx6ul_linux_mfgtools

2. Copy the mfg mode uboot and kernel and initramfs into imx_usb_loader_imx6ul/firmware
    $ mkdir imx_usb_loader_imx6ul/firmware/
    $ cp XXX/zImage XXX/cpio.rootfs XXX/u-boot.imx imx_usb_loader_imx6ul/firmware/
    Notice the names should be the following :
        u-boot-imx6ul14x14evk_nand.imx
        zImage
        fsl-image-mfgtool-initramfs-imx_mfgtools.cpio.gz.u-boot
        zImage-imx6ul-14x14-evk-gpmi-weim.dtb
        u-boot-imx6ul14x14evk_nand.imx

3. Copy the files te be flashed into imx_usb_loader_imx6ul/files
    $ mkdir imx_usb_loader_imx6ul/files/
    $ cp XXX/zImage XXX/cpio.rootfs XXX/u-boot.imx imx_usb_loader_imx6ul/files/
    Notice the name of them should be:
        mbtcp-product-imx6ul-var-dart.tar.bz2  mys-imx6ul-14x14-evk-gpmi-weim-myb6ulx.dtb  u-boot.imx  zImage

4. Replace the imx_usb_loader config file:
    $ cp mx6_usb_work.conf imx_usb_loader_imx6ul/mx6_usb_work.conf
    Also the files in firmware directory is used in this config file

5. Change the boot mode of the board into Serial Download booting mode
    Then connect to PC, and use the lsusb to verify the HID device is
    recgonizated:
        $ lsusb | grep -i free
            Bus 003 Device 055: ID 15a2:007d Freescale Semiconductor, Inc. 

6. Flashing:
    $ cd ~/imx6ul_linux_mfgtools
    $ sudo ./board-flash.sh . ./utp-flash-commands.sh 


=================================================================================
Sample flashing logs:
$ sudo ./board-flash.sh . ./utp-flash-commands.sh 
a1: .
a2: ./utp-flash-commands.sh
a3: 
Searching for utp_com
Searching the scripts
Running the imx_usb to loading and booting linux
config file <./imx_usb.conf>
vid=0x066f pid=0x3780 file_name=mx23_usb_work.conf
vid=0x15a2 pid=0x004f file_name=mx28_usb_work.conf
vid=0x15a2 pid=0x0052 file_name=mx50_usb_work.conf
vid=0x15a2 pid=0x0054 file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x0061 file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x0063 file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x0071 file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x007d file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x0076 file_name=mx7_usb_work.conf
vid=0x15a2 pid=0x0041 file_name=mx51_usb_work.conf
vid=0x15a2 pid=0x004e file_name=mx53_usb_work.conf
vid=0x15a2 pid=0x006a file_name=vybrid_usb_work.conf
vid=0x066f pid=0x37ff file_name=linux_gadget.conf
no matching USB device found
Getting the SG devices to obtain the SG device name of the board in UTP mode
Waiting for 12 Seconds...
Device is: /dev/sg3
-> Writing boot partition
-> Sending u-boot.bin
-> Write u-boot into nand
-> Sending kernel zImage
-> Writing kernel...
-> Sending Device Tree file
-> Writing device tree file to sd card @ p1
-> erase rootfs partition...
-> ubi format...
-> ubi attaching...
-> ubi mkimgvol...
-> ubi mount...
-> Sending and Flashing rootfs partition to sd card @ p2
-> Finishing rootfs image write on mtd3
...........


======================================================================
Reference & Orinial guide
    https://community.nxp.com/thread/441563
