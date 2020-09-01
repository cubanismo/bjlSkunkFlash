// PatchBin.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdio.h>

int _tmain(int argc, _TCHAR* argv[])
{
	if (argc < 3) {
		printf("Makes simple binary modification to a file\n");
		printf("patchbin <filename> <offset in hex> <hex byte> <hex byte> <hex byte>...\n");
		printf("ex: patchbin myfile.dat 12a5 22 88 9a\n");
		printf("** WARNING: MAKES NO BACKUP!  **\n");
		return 1;
	}

	FILE *fp=fopen(argv[1], "rb+");
	if (NULL == fp) {
		printf("Failed to open file '%s'\n", argv[1]);
		return 2;
	}

	int x;
	if (1 != sscanf(argv[2], "%x", &x)) {
		printf("Failed to parse offset\n");
		return 3;
	}

	if (0 != fseek(fp, x, SEEK_SET)) {
		printf("Seek to 0x%x failed\n", x);
		return 4;
	}

	for (int z=3; z<argc; z++) {
		if (1 != sscanf(argv[z], "%x", &x)) {
			printf("Failed to parse data argument %d\n", z);
			return 5;
		}
		fputc(x, fp);
	}

	fclose(fp);
	printf("Patched!\n");

	return 0;
}

