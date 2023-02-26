.PHONY: libjson libjson-build libjson-test

LIBJSON_MAJOR		:= 0
LIBJSON_MINOR		:= 1
LIBJSON_PATCH		:= 0
LIBJSON_VERSION		:= $(LIBJSON_MAJOR).$(LIBJSON_MINOR).$(LIBJSON_PATCH)

LIBJSON_CFLAGS		:= \
			   $(CFLAGS) \
			   $(CPPFLAGS) \
			   -DLIBJSON_VERSION_MAJOR="\"$(LIBJSON_MAJOR)"\" \
			   -DLIBJSON_VERSION_MINOR="\"$(LIBJSON_MINOR)"\" \
			   -DLIBJSON_VERSION_PATCH="\"$(LIBJSON_PATCH)"\" \
			   -DLIBJSON_VERSION="\"$(LIBJSON_VERSION)"\" \
			   -Ilibjson/include -Ilibmbs/include

LIBJSON_FLAGS		:= \
			   $(LIBJSON_CFLAGS) \
			   $(LDFLAGS) -lmbs

LIBJSON_SOURCES		:= libjson/src/libjson.c

LIBJSON_OBJECTS		:= $(LIBJSON_SOURCES:%.c=$(OBJ)/%.c.o)
LIBJSON_OBJDEPS		:= $(LIBJSON_OBJECTS:%.o=%.d)

-include $(LIBJSON_OBJDEPS)

LIBJSON_TEST_SOURCES	:= libjson/tests/test_libjson.c

LIBJSON_TEST_OBJECTS	:= $(LIBJSON_TEST_SOURCES:%.c=$(TST)/%.x)

$(LIBJSON_OBJECTS): $(OBJ)/%.c.o: %.c | $(OBJ)
	@mkdir -p $(dir $@)
	$(CC) -MMD -o $@ -c $< $(LIBJSON_CFLAGS)

$(LIBJSON_TEST_OBJECTS): $(TST)/%.x: libjson-test-deps %.c $(LIBJSON_OBJECTS) | $(TST)
	@mkdir -p $(dir $@)
	$(CC) -static -o $@ $(wordlist 2,$(words $^),$^) $(LIBJSON_FLAGS)

$(LIB)/libjson.$(LIBJSON_VERSION).a: libjson-deps $(LIBJSON_OBJECTS) | $(LIB)
	@mkdir -p $(dir $@)
	$(AR) -rcs $@ $(wordlist 2,$(words $^),$^)

$(LIB)/libjson.$(LIBJSON_MAJOR).a: $(LIB)/libjson.$(LIBJSON_VERSION).a
	ln -sf $(notdir $<) $@

$(LIB)/libjson.a: $(LIB)/libjson.$(LIBJSON_MAJOR).a
	ln -sf $(notdir $<) $@

$(LIB)/libjson.$(LIBJSON_VERSION).so: libjson-deps $(LIBJSON_OBJECTS) | $(LIB)
	@mkdir -p $(dir $@)
	$(CC) -shared -o $@ $(wordlist 2,$(words $^),$^) $(LIBJSON_FLAGS)

$(LIB)/libjson.$(LIBJSON_MAJOR).so: $(LIB)/libjson.$(LIBJSON_VERSION).so
	ln -sf $(notdir $<) $@

$(LIB)/libjson.so: $(LIB)/libjson.$(LIBJSON_MAJOR).so
	ln -sf $(notdir $<) $@

libjson-deps: $(LIB)/libmbs.a

libjson-build: $(LIB)/libjson.a $(LIB)/libjson.so

libjson-test-deps: $(LIB)/libmbs.a

libjson-test: $(LIBJSON_TEST_OBJECTS)
	@for f in $(LIBJSON_TEST_OBJECTS); do ./$$f ; done

libjson: libjson-build libjson-test
