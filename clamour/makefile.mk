.PHONY: clamour clamour-build clamour-test

CLAMOUR_MAJOR		:= 0
CLAMOUR_MINOR		:= 1
CLAMOUR_PATCH		:= 0
CLAMOUR_VERSION		:= $(CLAMOUR_MAJOR).$(CLAMOUR_MINOR).$(CLAMOUR_PATCH)

CLAMOUR_CFLAGS		:= \
			   $(CFLAGS) \
			   $(CPPFLAGS) \
			   -DCLAMOUR_VERSION_MAJOR="\"$(CLAMOUR_MAJOR)"\" \
			   -DCLAMOUR_VERSION_MINOR="\"$(CLAMOUR_MINOR)"\" \
			   -DCLAMOUR_VERSION_PATCH="\"$(CLAMOUR_PATCH)"\" \
			   -DCLAMOUR_VERSION="\"$(CLAMOUR_VERSION)"\" \
			   -Iclamour/include -Ilibmbs/include -Ilibdiscord/include -Ilibjson/include -Ilibweb/include

CLAMOUR_FLAGS		:= \
			   $(CLAMOUR_CFLAGS) \
			   $(LDFLAGS) -lmbs -ldiscord -ljson -lweb

CLAMOUR_SOURCES		:= clamour/src/clamour.c

CLAMOUR_OBJECTS		:= $(CLAMOUR_SOURCES:%.c=$(OBJ)/%.c.o)
CLAMOUR_OBJDEPS		:= $(CLAMOUR_OBJECTS:%.o=%.d)

-include $(CLAMOUR_OBJDEPS)

CLAMOUR_TEST_SOURCES	:= clamour/tests/test_clamour.c

$(CLAMOUR_OBJECTS): $(OBJ)/%.c.o: %.c | $(OBJ)
	@mkdir -p $(dir $@)
	$(CC) -MMD -o $@ -c $< $(CLAMOUR_CFLAGS)

$(BIN)/clamour: clamour-deps $(CLAMOUR_OBJECTS) | $(BIN)
	@mkdir -p $(dir $@)
	$(CC) -o $@ $(wordlist 2,$(words $^),$^) $(CLAMOUR_FLAGS)

clamour-deps: $(LIB)/libmbs.a $(LIB)/libdiscord.so $(LIB)/libjson.so $(LIB)/libweb.so

clamour-build: $(BIN)/clamour

clamour-test-deps: $(LIB)/libmbs.a $(LIB)/libdiscord.a $(LIB)/libjson.a $(LIB)/libweb.a

clamour-test:

clamour: clamour-build clamour-test
