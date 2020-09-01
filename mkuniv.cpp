// Replace the headder on a regular ROM file with the universal encryption bypass
// header.
#include <stdio.h>
#include "univbin.h"

int main(int argc, char* argv[])
{
	if (argc != 2) {
		printf("Add a universal header to the specified ROM.\n");
		printf("\n  Usage: mkuniv <ROM file>\n\n");
		return 1;
	}

	FILE *fp=fopen(argv[1], "rb+");
	if (NULL == fp) {
		printf("Failed to open file '%s'\n", argv[1]);
		return 2;
	}

	if (fwrite(univbin, 1, sizeof(univbin), fp) != sizeof(univbin)) {
		printf("Failed to write header to file\n");
		return 3;
	}

	fclose(fp);
	printf("Universal Header Written!\n");

	return 0;
}

