#!/bin/bash -x

DEV=$1

if [ ! -b "$DEV" ]; then
	echo "Usage: $0 /dev/firstpartitionofusb"
	exit 1;
fi

mount | grep $DEV > /dev/null 2>&1
if [ "$?" = "0" ]; then
	echo "Cannot write image while mounted"
	mount | grep "$DEV"
	exit
fi

mkfs.vfat $DEV
if [ $? != 0 ]; then
	echo "mkfs failed"
	exit 1;
fi

TEMPDIR=$(mktemp -d)
mount $DEV $TEMPDIR
if [ $? != 0 ]; then
	echo "mount failed"
	cat $LOGFILE
	rm $LOGFILE
	exit
fi

mkdir ${TEMPDIR}/boot/
cp output/images/rootfs.cpio.uboot ${TEMPDIR}/boot/
cp output/images/*.dtb ${TEMPDIR}/boot/
cp output/images/uImage ${TEMPDIR}/boot/
cp blast.sh ${TEMPDIR}/
cp tsinit.scr ${TEMPDIR}/
mkimage -T script -C none -A arm -n 'usb boot' -d tsinit.scr ${TEMPDIR}/tsinit.ub
umount ${TEMPDIR}
sync
