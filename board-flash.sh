#!/bin/bash

# p1.- imx_loader and utp_com path
# p2.- Flashing script with the UTP commands

RED='\e[1;37;41m'
GREEN='\e[1;37;42m'
YELLOW='\e[1;33m'
NC='\e[0m'

WORKING_DIR=`pwd`
IMX_USB_LOADER_NAME=imx_usb
UTP_COM_NAME=utp_com

echo "a1: $1"
echo "a2: $2"
echo "a3: $3"
# Search for the paths where imx USB loader and UTP com apps are located
#IMX_USB_PATH=$1/imx_usb_loader
IMX_USB_PATH=$1/imx_usb_loader_imx6ul
IMX_USB_PATH=`realpath $IMX_USB_PATH`

echo "Searching loader at: $IMX_USB_PATH/$IMX_USB_LOADER_NAME "

if [ ! -x $IMX_USB_PATH/$IMX_USB_LOADER_NAME ]
then
    echo -e "${RED}-imx_usb_loader- application not found!${NC}"
    echo -e "${YELLOW}Make sure that the <imx_usb_loader/imx_usb> app exists in the specified path${NC}"
    exit 1  # fail
fi

echo "Searching for utp_com"
UTP_COM_PATH=$1/utp_com

if [ ! -x $UTP_COM_PATH/$UTP_COM_NAME ]
then
    echo -e "${RED}-utp_com- application not found!${NC}"
    echo -e "${YELLOW}Make sure that the <utp_com/utp_com> app exists in the specified path${NC}"
    exit 1  # fail
fi

# Establish the location of the files that will be flashed to the board
#FLASH_IMAGE_DIR=$WORKING_DIR/build/tmp/deploy/images/imx6sxsabresd
#MFG_IMAGE_DIR=$FLASH_IMAGE_DIR
#FLASH_IMAGE_DIR=/ExtDisk2/Projects/Yocto_iMX6UL_Variscite_Rocko/MYer_BSP/MFG_Linux/imx_usb_loader_imx6ul/files
FLASH_IMAGE_DIR=$IMX_USB_PATH/files
#MFG_IMAGE_DIR=$FLASH_IMAGE_DIR

echo "Searching the scripts"
if [[ -x ./$2 ]]
then
    APP_FLASHING_SCRIPT=$2
else
    echo -e "${RED}Invalid second input parameter${NC}" 
    echo -e "${YELLOW}It should be the name of the flashing script to execute${NC}"
    echo -e "${YELLOW}Check that the second parameter is an executable bash script${NC}"
    exit 1  # fail
fi

# Go to the imx_usb_loader folder
cd $IMX_USB_PATH

# Create the folder to transfer the Mfg files from their original location
#mkdir firmware

# Here we get a copy of the /dev folder looking for "sg" devices (SCSI devices)
ls /dev/sg* | grep "sg" > firmware/dev-temp1.txt

echo "Running the imx_usb to loading and booting linux"
IMX_USB_PRINT=`sudo ./imx_usb 2>&1`

if `echo "$IMX_USB_PRINT" | grep -q "Could not open device"`; then
    echo -e "${RED}imx_usb returned error: Could not open device${NC}"
    echo -e "${YELLOW}Try disconnecting and reconnecting the device and run this script again${NC}"
    exit 1
fi

if `echo "$IMX_USB_PRINT" | grep -q "no matching USB device found"`; then
    echo -e "${RED}imx_usb returned error: No matching USB device found${NC}"
    echo -e "${YELLOW}Please make sure the board is connected to the USB port and the jumper is set to 'serial downloader mode'${NC}"
    exit 1
fi

if `echo "$IMX_USB_PRINT" | grep -q "err=-"`; then
    echo -e "${RED}imx_usb returned error:${NC}"
    echo $IMX_USB_PRINT
    exit 1
fi

# Copy the mfg files from the 'images' folder to the imx_usb_loader folder.
#cp $MFG_IMAGE_DIR/u-boot-imx6sxsabresd-mfgtool.imx firmware/u-boot-imx6sxsabresd-mfgtool.imx
#cp $MFG_IMAGE_DIR/zImage_mfgtool firmware/zImage-mfgtool-imx6sxsabresd.bin
#cp $MFG_IMAGE_DIR/zImage-mfgtool-imx6sx-sdb.dtb firmware/zImage-mfgtool-imx6sx-sdb.dtb
#cp $MFG_IMAGE_DIR/fsl-image-mfgtool-initramfs-imx6sxsabresd.cpio.gz.u-boot firmware/fsl-image-mfgtool-initramfs-imx6sxsabresd.cpio.gz.u-boot

# Execute imx_usb_loader to load into the board RAM the flashing OS
sudo ./imx_usb

echo "Getting the SG devices to obtain the SG device name of the board in UTP mode"
echo "Waiting for 12 Seconds..."
sleep 12
ls /dev/sg* | grep "sg" > firmware/dev-temp2.txt

# Get the SG device corresponding to the board by comparing the contents of /dev before
# and after our board is enumerated as a SCSI device.
DEVICE=`diff firmware/dev-temp1.txt firmware/dev-temp2.txt | grep '/dev/sg' | cut -c 3-`
echo "Device is: $DEVICE"

# Delete the temporary files used
#rm -rf firmware/
echo WorkingDir: $WORKING_DIR .
echo ./$APP_FLASHING_SCRIPT $UTP_COM_PATH $DEVICE $WORKING_DIR $FLASH_IMAGE_DIR
#  ./utp-flash-commands.sh  ./utp_com     /dev/sg3    .  /ExtDisk2/Projects/Yocto_iMX6UL_Variscite_Rocko/MYer_BSP/MFG_Linux/imx_usb_loader_imx6ul/files
# Return to the project folder and call the script with the UTP commands
cd $WORKING_DIR
./$APP_FLASHING_SCRIPT $UTP_COM_PATH $DEVICE $WORKING_DIR $FLASH_IMAGE_DIR
