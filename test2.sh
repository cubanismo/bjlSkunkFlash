#!/bin/sh

if [ -f e2p.log ]; then
	rm e2p.log
fi

if [ -f test.e2p ]; then
	rm test.e2p
fi

if [ -f test.bin ]; then
	rm test.bin
fi

if [ -f bios.bin ]; then
	rm bios.bin
fi

failed() {
	echo -------------- FAILED ---------------
	exit 1
}

e2ptests() {
	echo
	echo "*******************************************"
	echo "*******************************************"
	echo "****                                   ****"
	echo "****    BEGIN SERIAL EEPROM TESTING    ****"
	echo "****                                   ****"
	echo "*******************************************"
	echo "*******************************************"
	echo
	
	echo .
	echo "Write random data to EEPROM 1 (93C46)"
	echo .
	jcp -k 1
	jcp -p rand-128.e2p |tee e2p.log
	grep 'Detected 93C46' e2p.log>/dev/null
	if [ $? -ne 0 ]; then failed; fi
	
	echo .
	echo "Write random data to EEPROM 2 (93C86)"
	echo .
	jcp -k 2
	jcp -p rand-2048.e2p |tee e2p.log
	grep 'Detected 93C86' e2p.log>/dev/null
	if [ $? -ne 0 ]; then failed; fi
	
	echo .
	echo Try to write data while both EEPROMs are disabled
	echo .
	jcp -k 0
	jcp -p rand-128.e2p | tee > e2p.log
	grep 'No supported serial EEPROM' e2p.log>/dev/null
	if [ $? -ne 0 ]; then failed; fi
	
	echo .
	echo "Read data back from EEPROM 1 (93C46) and compare to data written"
	echo .
	jcp -k 1
	jcp -g test.e2p |tee e2p.log
	grep 'Detected 93C46' e2p.log>/dev/null
	if [ $? -ne 0 ]; then failed; fi
	echo Diff the files...
	diff --binary test.e2p rand-128.e2p
	if [ $? -ne 0 ]; then failed; fi
	
	echo .
	echo "Read data back from EEPROM 2 (93C86) and compare to data written"
	echo .
	jcp -k 2
	jcp -g test.e2p |tee e2p.log
	grep 'Detected 93C86' e2p.log>/dev/null
	if [ $? -ne 0 ]; then failed; fi
	echo Diff the files...
	diff --binary test.e2p rand-2048.e2p
	if [ $? -ne 0 ]; then failed; fi
	
	echo .
	echo Clear both EEPROM banks
	echo .
	jcp -k 1
	jcp -p ffff.e2p |tee e2p.log
	grep 'Detected 93C46' e2p.log>/dev/null
	if [ $? -ne 0 ]; then failed; fi
	jcp -k 2
	jcp -p ffff.e2p |tee e2p.log
	grep 'Detected 93C86' e2p.log>/dev/null
	if [ $? -ne 0 ]; then failed; fi
}

jcp -r
sleep 3
echo ""
echo "** Please check the serial number is valid! **"
echo ""
jcp '-*'
sleep 3

BIOS_SERIAL="`jcp -s | tail -n 1`"
BIOS_MAJOR="`echo $BIOS_SERIAL | cut -c 16,17`"
BIOS_MINOR="`echo $BIOS_SERIAL | cut -c 19,20`"
BIOS_PATCH="`echo $BIOS_SERIAL | cut -c 22,23`"
BIOS_MAJOR=`expr 0 + $BIOS_MAJOR`
BIOS_MINOR=`expr 0 + $BIOS_MINOR`
BIOS_PATCH=`expr 0 + $BIOS_PATCH`
BIOS_FILE="skunkbios_${BIOS_MAJOR}.${BIOS_MINOR}.${BIOS_PATCH}.bin"

echo "Skunk BIOS Version: ${BIOS_MAJOR}.${BIOS_MINOR}.${BIOS_PATCH}"

echo .
echo Dumping the BIOS...
echo .
jcp -c biosdump.cof
echo clear serial number
./patchbin bios.bin 808 0 0 0 0
echo Compare to baseline...
diff --binary bios.bin "$BIOS_FILE"
if [ $? -ne 0 ]; then
	failed
fi
jcp -r
sleep 3

echo .
echo Update the BIOS if necessary...
echo .
jcp -u
sleep 3
echo ""
echo "** Please check the serial number is *still* valid! **"
echo ""
jcp '-*'
sleep 3

echo .
echo Load the zeros file to bank 1...
echo .
jcp -f zerocart.bin
sleep 3
jcp -r
sleep 3
echo Now dump it back...
jcp -d test.bin
echo Diff the files...
diff --binary zerocart.bin test.bin
if [ $? -ne 0 ]; then
	failed
fi
sleep 3

echo .
echo Try a game in bank 1...
echo .
jcp -f doom.jag
echo Letting it run for 2 minutes...
sleep 120
jcp -r
sleep 3

echo .
echo Load the zeros file to bank 2...
echo .
jcp -2f zerocart.bin
sleep 3
jcp -r
sleep 3

echo Now dump it back...
jcp -2d test.bin
echo Diff the files...
diff --binary zerocart.bin test.bin
if [ $? -ne 0 ]; then
	failed
fi
sleep 3

echo .
echo Now dump bank 1 to check game...
echo .
jcp -d test.bin
echo Diff the files...
diff --binary doom.jag test.bin
if [ $? -ne 0 ]; then
	failed
fi
sleep 3

echo .
echo Try a game in bank 2...
echo .
jcp -2f avp.jag
echo Letting it run for 2 minutes...
sleep 120
jcp -r
sleep 3

echo .
echo Write the zeros back to bank 1
echo .
jcp -f zerocart.bin
sleep 3
jcp -r
sleep 3

echo .
echo Now dump bank 2 back...
echo .
jcp -2d test.bin
echo Diff the files...
diff --binary avp.jag test.bin
if [ $? -ne 0 ]; then
	failed
fi
sleep 3

echo .
echo Try a 6MB game...
echo .
jcp -6f badapple.rom
echo Letting it run for 4 minutes 10 seconds
sleep 250
jcp -r
sleep 3

echo .
echo Now dump 6MB back...
echo .
jcp -6d test.bin
echo Diff the files...
diff --binary badapple.rom test.bin
if [ $? -ne 0 ]; then
	failed
fi
sleep 3

echo .
echo Write the zeros back to bank 2
echo .
jcp -2f zerocart.bin
sleep 3
jcp -r
sleep 3

echo .
echo Write the zeros back to bank 1
echo .
jcp -f zerocart.bin
sleep 3
jcp -r
sleep 3

if [ ${BIOS_MAJOR} -ge 4 ]; then
	e2ptests
fi

echo .
echo !!!!!SUCCESS!!!!!
rm -f bios.bin test.bin test.e2p e2p.log

exit 0
