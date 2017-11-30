#!/bin/bash

RED='\e[1;37;41m'
GREEN='\e[1;37;42m'
YELLOW='\e[1;33m'
NC='\e[0m'

# Use the UTP_COM utility to flash the application images
cd $1

# Create Partition
#echo -e "${YELLOW}-> Sending partitioning shell script${NC}"
#./utp_com -d $2 -c "send" -f ${3}/mksdcard.sh.tar
#echo -e "${YELLOW}-> Decompresing script...${NC}"
#./utp_com -d $2 -c "$ tar xf \$FILE"
#echo -e "${YELLOW}-> Partitioning eMMC${NC}"
#./utp_com -d $2 -c "$ sh mksdcard.sh /dev/mmcblk3"

# Setup u-boot partition
echo -e "${YELLOW}-> Writing boot partition${NC}"
./utp_com -d $2 -c "$ flash_erase /dev/mtd0 0 0"
echo -e "${YELLOW}-> Sending u-boot.bin${NC}"
./utp_com -d $2 -c "send" -f ${4}/u-boot.imx
echo -e "${YELLOW}-> Write u-boot into nand${NC}"
./utp_com -d $2 -c "$ kobs-ng -x -v --chip_0_path=/dev/mtd0 \$FILE "
#echo -e "${YELLOW}-> Re-enable read-only${NC}"
#./utp_com -d $2 -c "$ echo 1 > /sys/block/mmcblk3boot0/force_ro"
#echo -e "${YELLOW}-> Enable boot partion 1 to boot${NC}"
#./utp_com -d $2 -c "$ mmc bootpart enable 1 1 /dev/mmcblk3"

# Create FAT partition
#echo -e "${YELLOW}-> Waiting for the partition ready${NC}"
#./utp_com -d $2 -c "$ while [ ! -e /dev/mmcblk3p1 ]; do sleep 1; echo \"waiting...\"; done "
#echo -e "${YELLOW}-> Formatting zImage partition p1${NC}"
#./utp_com -d $2 -c "$ mkfs.vfat /dev/mmcblk3p1"
#./utp_com -d $2 -c "$ mkdir -p /mnt/mmcblk3p1"
#./utp_com -d $2 -c "$ mount -t vfat /dev/mmcblk3p1 /mnt/mmcblk3p1"

# Burn zImage (Kernel) on p1
echo -e "${YELLOW}-> Sending kernel zImage${NC}"
./utp_com -d $2 -c "$ flash_erase /dev/mtd1 0 0"
./utp_com -d $2 -c "send" -f ${4}/zImage
echo -e "${YELLOW}-> Writing kernel...${NC}"
./utp_com -d $2 -c "$ nandwrite -p /dev/mtd1 \$FILE"

# Burn dtb on p1
echo -e "${YELLOW}-> Sending Device Tree file${NC}"
./utp_com -d $2 -c "$ flash_erase /dev/mtd2 0 0"
#./utp_com -d $2 -c "send" -f ${4}/zImage-imx6sx-sdb.dtb
./utp_com -d $2 -c "send" -f ${4}/mys-imx6ul-14x14-evk-gpmi-weim-myb6ulx.dtb
echo -e "${YELLOW}-> Writing device tree file to sd card @ p1${NC}"
./utp_com -d $2 -c "$ nandwrite -p /dev/mtd2 \$FILE"
#echo -e "${YELLOW}-> Unmounting vfat partition${NC}"
#./utp_com -d $2 -c "$ umount /mnt/mmcblk3p1"

# Populate default rootfs on p2
echo -e "${YELLOW}-> erase rootfs partition...${NC}"
./utp_com -d $2 -c "$ flash_erase /dev/mtd3 0 0"
echo -e "${YELLOW}-> ubi format...${NC}"
./utp_com -d $2 -c "$ ubiformat /dev/mtd3"
echo -e "${YELLOW}-> ubi attaching...${NC}"
./utp_com -d $2 -c "$ ubiattach /dev/ubi_ctrl -m 3"
echo -e "${YELLOW}-> ubi mkimgvol...${NC}"
./utp_com -d $2 -c "$ ubimkvol /dev/ubi0 -Nrootfs -m"
./utp_com -d $2 -c "$ mkdir -p /mnt/mtd3"
echo -e "${YELLOW}-> ubi mount...${NC}"
./utp_com -d $2 -c "$ mount -t ubifs ubi0:rootfs /mnt/mtd3"
echo -e "${YELLOW}-> Sending and Flashing rootfs partition to sd card @ p2${NC}"
./utp_com -d $2 -c "pipe tar -jx -C /mnt/mtd3" -f ${4}/mbtcp-product-imx6ul-var-dart.tar.bz2
echo -e "${YELLOW}-> Finishing rootfs image write on mtd3${NC}"
./utp_com -d $2 -c "frf"
echo -e "${YELLOW}-> Unmounting rootfs partition${NC}"
./utp_com -d $2 -c "$ umount /mnt/mtd3"

# Done
echo "   "
echo -e "${GREEN}                            ${NC}"
echo -e "${GREEN} -> Board Setup Complete <- ${NC}"
echo -e "${GREEN}                            ${NC}"
echo "   "
./utp_com -d $2 -c "$ echo Update Ready"
