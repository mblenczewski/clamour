/*
 * Copyright (c) 2023, Mikolaj Lenczewski <mblenczewski@gmail.com>
 *
 * SPDX-License-Identifier: MIT-0
 */

#include "libmbs/test.h"
#include "libweb.h"

s32
test_example(void) {
	int a = 42;

	TEST_EXPECT(a + 2 == 44, "a + 2 != 44")
	TEST_ASSERT(a == 42, "a != 42")

	TEST_PASS()
}

s32
main(s32 argc, char **argv) {
	(void)argc;
	(void)argv;

	TESTS_BEGIN()

	TEST_RUN(test_example)

	TESTS_END()
}
