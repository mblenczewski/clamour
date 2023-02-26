/*
 * Copyright (c) 2023, Mikolaj Lenczewski <mblenczewski@gmail.com>
 *
 * SPDX-License-Identifier: MIT-0
 */

#include "clamour.h"

s32
main(s32 argc, char **argv) {
	(void)argc;
	(void)argv;

	dbglog("Version: " CLAMOUR_VERSION "\n");
	printf("Hello, World!\n");

	return 0;
}
