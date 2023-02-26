.PHONY: libdiscord libdiscord-build libdiscord-test

LIBDISCORD_MAJOR	:= 0
LIBDISCORD_MINOR	:= 1
LIBDISCORD_PATCH	:= 0
LIBDISCORD_VERSION	:= $(LIBDISCORD_MAJOR).$(LIBDISCORD_MINOR).$(LIBDISCORD_PATCH)

LIBDISCORD_CFLAGS	:= \
			   $(CFLAGS) \
			   $(CPPFLAGS) \
			   -DLIBDISCORD_VERSION_MAJOR="\"$(LIBDISCORD_MAJOR)"\" \
			   -DLIBDISCORD_VERSION_MINOR="\"$(LIBDISCORD_MINOR)"\" \
			   -DLIBDISCORD_VERSION_PATCH="\"$(LIBDISCORD_PATCH)"\" \
			   -DLIBDISCORD_VERSION="\"$(LIBDISCORD_VERSION)"\" \
			   -Ilibdiscord/include -Ilibmbs/include -Ilibweb/include

LIBDISCORD_FLAGS	:= \
			   $(LIBDISCORD_CFLAGS) \
			   $(LDFLAGS) -lmbs -lweb

LIBDISCORD_SOURCES	:= libdiscord/src/libdiscord.c

LIBDISCORD_OBJECTS	:= $(LIBDISCORD_SOURCES:%.c=$(OBJ)/%.c.o)
LIBDISCORD_OBJDEPS	:= $(LIBDISCORD_OBJECTS:%.o=%.d)

-include $(LIBDISCORD_OBJDEPS)

LIBDISCORD_TEST_SOURCES	:= libdiscord/tests/test_libdiscord.c

LIBDISCORD_TEST_OBJECTS	:= $(LIBDISCORD_TEST_SOURCES:%.c=$(TST)/%.x)

$(LIBDISCORD_OBJECTS): $(OBJ)/%.c.o: %.c | $(OBJ)
	@mkdir -p $(dir $@)
	$(CC) -MMD -o $@ -c $< $(LIBDISCORD_CFLAGS)

$(LIBDISCORD_TEST_OBJECTS): $(TST)/%.x: libdiscord-test-deps %.c $(LIBDISCORD_OBJECTS) | $(TST)
	@mkdir -p $(dir $@)
	$(CC) -static -o $@ $(wordlist 2,$(words $^),$^) $(LIBDISCORD_FLAGS)

$(LIB)/libdiscord.$(LIBDISCORD_VERSION).a: libdiscord-deps $(LIBDISCORD_OBJECTS) | $(LIB)
	@mkdir -p $(dir $@)
	$(AR) -rcs $@ $(wordlist 2,$(words $^),$^)

$(LIB)/libdiscord.$(LIBDISCORD_MAJOR).a: $(LIB)/libdiscord.$(LIBDISCORD_VERSION).a
	ln -sf $(notdir $<) $@

$(LIB)/libdiscord.a: $(LIB)/libdiscord.$(LIBDISCORD_MAJOR).a
	ln -sf $(notdir $<) $@

$(LIB)/libdiscord.$(LIBDISCORD_VERSION).so: libdiscord-deps $(LIBDISCORD_OBJECTS) | $(LIB)
	@mkdir -p $(dir $@)
	$(CC) -shared -o $@ $(wordlist 2,$(words $^),$^) $(LIBDISCORD_FLAGS)

$(LIB)/libdiscord.$(LIBDISCORD_MAJOR).so: $(LIB)/libdiscord.$(LIBDISCORD_VERSION).so
	ln -sf $(notdir $<) $@

$(LIB)/libdiscord.so: $(LIB)/libdiscord.$(LIBDISCORD_MAJOR).so
	ln -sf $(notdir $<) $@

libdiscord-deps: $(LIB)/libmbs.a $(LIB)/libweb.so

libdiscord-build: $(LIB)/libdiscord.a $(LIB)/libdiscord.so

libdiscord-test-deps: $(LIB)/libmbs.a $(LIB)/libweb.a

libdiscord-test: $(LIBDISCORD_TEST_OBJECTS)
	@for f in $(LIBDISCORD_TEST_OBJECTS); do ./$$f ; done

libdiscord: libdiscord-build libdiscord-test
