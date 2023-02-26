.PHONY: libweb libweb-build libweb-test

LIBWEB_MAJOR		:= 0
LIBWEB_MINOR		:= 1
LIBWEB_PATCH		:= 0
LIBWEB_VERSION		:= $(LIBWEB_MAJOR).$(LIBWEB_MINOR).$(LIBWEB_PATCH)

LIBWEB_CFLAGS		:= \
			   $(CFLAGS) \
			   $(CPPFLAGS) \
			   -DLIBWEB_VERSION_MAJOR="\"$(LIBWEB_MAJOR)"\" \
			   -DLIBWEB_VERSION_MINOR="\"$(LIBWEB_MINOR)"\" \
			   -DLIBWEB_VERSION_PATCH="\"$(LIBWEB_PATCH)"\" \
			   -DLIBWEB_VERSION="\"$(LIBWEB_VERSION)"\" \
			   -Ilibweb/include -Ilibmbs/include

LIBWEB_FLAGS		:= \
			   $(LIBWEB_CFLAGS) \
			   $(LDFLAGS) -lmbs

LIBWEB_SOURCES		:= libweb/src/libweb.c

LIBWEB_OBJECTS		:= $(LIBWEB_SOURCES:%.c=$(OBJ)/%.c.o)
LIBWEB_OBJDEPS		:= $(LIBWEB_OBJECTS:%.o=%.d)

-include $(LIBWEB_OBJDEPS)

LIBWEB_TEST_SOURCES	:= libweb/tests/test_libweb.c

LIBWEB_TEST_OBJECTS	:= $(LIBWEB_TEST_SOURCES:%.c=$(TST)/%.x)

$(LIBWEB_OBJECTS): $(OBJ)/%.c.o: %.c | $(OBJ)
	@mkdir -p $(dir $@)
	$(CC) -MMD -o $@ -c $< $(LIBWEB_CFLAGS)

$(LIBWEB_TEST_OBJECTS): $(TST)/%.x: libweb-test-deps %.c $(LIBWEB_OBJECTS) | $(TST)
	@mkdir -p $(dir $@)
	$(CC) -static -o $@ $(wordlist 2,$(words $^),$^) $(LIBWEB_FLAGS)

$(LIB)/libweb.$(LIBWEB_VERSION).a: libweb-deps $(LIBWEB_OBJECTS) | $(LIB)
	@mkdir -p $(dir $@)
	$(AR) -rcs $@ $(wordlist 2,$(words $^),$^)

$(LIB)/libweb.$(LIBWEB_MAJOR).a: $(LIB)/libweb.$(LIBWEB_VERSION).a
	ln -sf $(notdir $<) $@

$(LIB)/libweb.a: $(LIB)/libweb.$(LIBWEB_MAJOR).a
	ln -sf $(notdir $<) $@

$(LIB)/libweb.$(LIBWEB_VERSION).so: libweb-deps $(LIBWEB_OBJECTS) | $(LIB)
	@mkdir -p $(dir $@)
	$(CC) -shared -o $@ $(wordlist 2,$(words $^),$^) $(LIBWEB_FLAGS)

$(LIB)/libweb.$(LIBWEB_MAJOR).so: $(LIB)/libweb.$(LIBWEB_VERSION).so
	ln -sf $(notdir $<) $@

$(LIB)/libweb.so: $(LIB)/libweb.$(LIBWEB_MAJOR).so
	ln -sf $(notdir $<) $@

libweb-deps: $(LIB)/libmbs.a

libweb-build: $(LIB)/libweb.a $(LIB)/libweb.so

libweb-test-deps: $(LIB)/libmbs.a

libweb-test: $(LIBWEB_TEST_OBJECTS)
	@for f in $(LIBWEB_TEST_OBJECTS); do ./$$f ; done

libweb: libweb-build libweb-test
