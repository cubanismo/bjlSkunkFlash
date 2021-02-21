#!/bin/sh

if [ -f usbdump0.bin ]; then
	rm usbdump0.bin
fi

if [ -f usbdump1.bin ]; then
	rm usbdump1.bin
fi

failed() {
	echo -------------- FAILED ---------------
	exit 1
}

if [ ! -r rand0.bin ]; then
	echo .
	echo Generating rand0.bin from /dev/urandom
	echo .
	dd if=/dev/urandom of=rand0.bin bs=1024 count=2048
fi

if [ ! -r rand1.bin ]; then
	echo .
	echo Generating rand1.bin from /dev/urandom
	echo .
	dd if=/dev/urandom of=rand1.bin bs=1024 count=2048
fi

echo .
echo Write rand0.bin to host USB port 0 and rand1.bin to host USB port 1,
echo then read them back to usbdump0.bin and usbdump1.bin respectively.
echo .
jcp -c usbverif.cof
echo Diff usbdump0 and rand0.bin...
diff --binary usbdump0.bin rand0.bin
if [ $? -ne 0 ]; then
	failed
fi
echo Diff usbdump1 and rand1.bin...
diff --binary usbdump1.bin rand1.bin
if [ $? -ne 0 ]; then
	failed
fi

echo .
echo !!!!!SUCCESS!!!!!
rm -f usbdump1.bin usbdump0.bin

exit 0
