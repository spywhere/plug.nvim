SOURCES:=$(sort $(wildcard src/*.lua))
BACKENDS:=$(sort $(wildcard backends/*.lua))
EXTENSIONS:=$(sort $(wildcard extensions/*.lua))
OUTPUT:=plug.lua
TEMPDIR:=$(shell mktemp -d)
PLACEHOLDER=to be calculated at compile time

.PHONY: %.lua plug.lua src/00_header.lua src/99_footer.lua

$(SOURCES): %.lua
$(BACKENDS): %.lua
$(EXTENSIONS): %.lua

%.lua:
	@echo
	@cat $@

header:
	@echo '------------------------------------------'
	@echo '-- this file is automatically generated --'
	@echo '--        do not edit directly          --'
	@echo '------------------------------------------'
	@echo "local build_checksum = \"$(PLACEHOLDER)\""
	@cat src/00_$@.lua

footer:
	@echo
	@cat src/99_$@.lua

preview: header $(SOURCES) $(BACKENDS) $(EXTENSIONS) footer

compile:
	@$(MAKE) preview > $(TEMPDIR)/$(OUTPUT)
	@CHECKSUM="$$(sha512sum $(TEMPDIR)/$(OUTPUT) | cut -d' ' -f1)" && \
	sed "s/\"$(PLACEHOLDER)\"/\"$$CHECKSUM\"/g" $(TEMPDIR)/$(OUTPUT) > $(OUTPUT)

backend.%:
	@sed 's/plug\.backend/plug.$@/g' $(TEMPDIR)/test.lua > $(TEMPDIR)/init.lua

tests/%:
	@cat $@.lua > $(TEMPDIR)/test.lua

drytest-auto-%: tests/auto backend.% compile
	@cat $(TEMPDIR)/init.lua

drytest-%: tests/init backend.% compile
	@cat $(TEMPDIR)/init.lua

test-auto-%: tests/auto backend.% compile
	nvim -u $(TEMPDIR)/init.lua

test-%: tests/init backend.% compile
	nvim -u $(TEMPDIR)/init.lua
