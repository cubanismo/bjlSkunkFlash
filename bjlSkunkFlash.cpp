// bjlSkunkFlash.cpp : Defines the entry point for the console application.
// Flashes a skunkboard, filling in the serial number, using the local skunkbios.cof file.
// Patches with the serial number, then invokes BJL (make sure it's in the path).

#include "stdafx.h"
#include <windows.h>

char szBJL[] = "bjlxp.exe";
char szArgs[]= "tmp.cof";

unsigned char bios[32*1024];
char buf[128];

int _tmain(int argc, _TCHAR* argv[])
{
	char *pEXE=szBJL;
	char *pARG=szArgs;
	char *pBIOS="skunkbios.cof";

	if (argc > 1) {
		pBIOS=argv[1];
	}
	if (argc > 2) {
		pEXE=argv[2];
	}
	if (argc > 3) {
		pARG=argv[3];
	}

	printf("Using BIOS file '%s'\n", pBIOS);
	printf("Using command line '%s %s'\n", pEXE, pARG);

	FILE *fp=fopen(pBIOS, "rb");
	if (NULL == fp) {
		printf("Can't open BIOS file!\n");
		return 1;
	}
	int nSize=fread(bios, 1, sizeof(bios), fp);
	fclose(fp);
	if (nSize < 100) {
		printf("Read error on BIOS file!\n");
		return 1;
	}
	int p=0;
	while (p<nSize) {
		if ((htonl(*(unsigned int*)&bios[p]) == 0xdeadbeef) &&
			(htonl(*(unsigned int*)&bios[p+4]) == 0xbeefdead)) {
				break;
		}
		p++;
	}
	if (p >= nSize) {
		printf("Can't find signature in BIOS file!\n");
		return 1;
	}

	int bootrev=htonl(*(int*)&bios[p-8]);

	printf("Ensure Jaguar is in BJL receive mode, ensure skunkboard is in machine.\n");
	printf("Also check BJL cable is attached! Boot revision %d.%d.%d\n\n", 
		(bootrev&0xff0000)>>16, (bootrev&0xff00)>>8, (bootrev&0xff));

lp:
	printf("Enter serial number for board in decimal format, 4 digits max (will save as hex): ");
	gets(buf);
	int serial;
	if (1 != sscanf(buf, "%x", &serial)) {
		printf("\nCan't read number!\n");
		goto lp;
	}

	// Updated number to start at 1101, since 10xx was for rev 1 boards.
	if ((serial<0x1101) || (serial > 0x9999)) {
		printf("Please use a range from 1101 to 9999\n");
		goto lp;
	}

	*(unsigned int*)&bios[p]=ntohl(serial);

	// Always writes tmp.cof, make sure that's in the arguments!
	fp=fopen("tmp.cof", "wb");
	if (NULL == fp) {
		printf("Can't write tmp.cof!\n");
		return 1;
	}
	fwrite(bios, 1, nSize, fp);
	fclose(fp);

	// invoke BJL
	printf("Writing serial number %04X to board, using command:\n", serial);
	printf("> %s %s\n", pEXE, pARG);

	int nRet=(int)ShellExecute(NULL, "open", pEXE, pARG, NULL, SW_SHOW);
	if (nRet < 32) {
		printf("Failed to shell, code %d\n", nRet);
	} else {
		printf("Done, wait for BJL to exit.\n");
	}

	return 0;
}

