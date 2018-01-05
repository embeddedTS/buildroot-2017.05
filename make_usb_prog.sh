#!/bin/bash -x

DEV=$1
MODEL=$2

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

#mkfs.vfat $DEV
mkfs.ext2 -F $DEV
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
cp output/images/*Image ${TEMPDIR}/boot/
cp blast${MODEL}.sh ${TEMPDIR}/blast.sh
cp tsinit${MODEL}.scr ${TEMPDIR}/tsinit.scr
mkimage -T script -C none -A arm -n 'usb boot' -d tsinit${MODEL}.scr ${TEMPDIR}/tsinit.ub
umount ${TEMPDIR}
sync
