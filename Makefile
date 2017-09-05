######################################################################
# Makefile user configuration
######################################################################

# Path to nodemcu-uploader (https://github.com/kmpm/nodemcu-uploader)
export NODEMCU-UPLOADER=$(CURDIR)/uploader/nodemcu-uploader.py

# Serial port
export PORT=/dev/ttyUSB0
export SPEED=115200

export NODEMCU-COMMAND=$(NODEMCU-UPLOADER) -b $(SPEED) --start_baud $(SPEED) -p $(PORT) upload

export PYTHON=$(CURDIR)/venv/bin/python

######################################################################

SRC_LUA_FILES := $(wildcard src/*.lua)
SRC_HTTP_FILES = $(wildcard src/http/*.html) $(wildcard src/http/*.js) $(wildcard src/http/*.lua) $(wildcard src/http/*.ico)
EXAMPLE_FILES := $(wildcard examples/*.html) $(wildcard examples/*.lua)

DIST := dist

SRC_DIST_FILES = $(wildcard $(DIST)/*.lua) $(wildcard $(DIST)/http/*.gz) $(wildcard $(DIST)/http/*.lua)
DIST_FILES = $(patsubst $(DIST)/%, %, $(SRC_DIST_FILES))

# Print usage
usage:
	@echo "make upload FILE:=<file>  to upload a specific file (i.e make upload FILE:=init.lua)"
	@echo "make upload_webide        to upload webide"
	@echo "make upload_examples      to upload examples"
	@echo "make upload_server        to upload the server code and init.lua"
	@echo "make upload_all           to upload all"
	@echo $(TEST)

help: usage

prepare: httpserver/Makefile patchserver

clean:
	@git submodule deinit -f .
	@rm -f $(DIST)/*.gz
	@rm -f $(DIST)/*.lua
	@rm -Rf $(DIST)/http

# make sure that the submodules are fetch
httpserver/Makefile:
	@echo Preparing submodules...
	@git submodule init
	@git submodule update

# Patch httpserver makefile for upload and init
patchserver: httpserver/makefile.patched httpserver/init.patched httpserver/httpserver.patched httpserver/httpserver-start.lua

httpserver/makefile.patched: patchs/httpserver_makefile.patch httpserver/Makefile
	@echo Patching httpserver makefile...
	@if [ -e $@ ]; then patch -p1 -R < $?; fi
	@patch -p1 < $?
	@touch ${@}

httpserver/init.patched: patchs/httpserver_init.patch httpserver/httpserver-compile.lua
	@echo Patching httpserver compile scripts...
	@if [ -e $@ ]; then patch -p1 -R < $?; fi
	@patch -p1 < $?
	@touch ${@}

httpserver/httpserver.patched: patchs/httpserver_httpserver.patch httpserver/httpserver.lua
	@echo Patching httpserver.lua ...
	@if [ -e $@ ]; then patch -p1 -R < $?; fi
	@patch -p1 < $?
	@touch ${@}

httpserver/httpserver-start.lua:
	@echo Replace httpserver init.lua by ${@}
	@mv httpserver/init.lua ${@}


install: compress copy_lua

# Compress files
compress: $(SRC_HTTP_FILES)
	@echo Compression HTTP files
	@install -d $(DIST)/http/
	@install $^ $(DIST)/http/
	@gzip -9 -f $(DIST)/http/*.html
	@gzip -9 -f $(DIST)/http/*.js
	@gzip -9 -f $(DIST)/http/*.ico

copy_lua: $(SRC_LUA_FILES)
	@cp $^ $(DIST)/

venv: prepare venv/bin/activate
venv/bin/activate: uploader/test_requirements.txt
	@test -d venv || virtualenv venv --python=python3
	@venv/bin/pip install -Ur $<
	@touch venv/bin/activate

# Upload one files only
upload: prepare venv
	@$(PYTHON) $(NODEMCU-COMMAND) $(FILE)

# Upload webide
upload_webide: prepare venv install
	@cd $(DIST) && $(PYTHON) $(NODEMCU-COMMAND) $(DIST_FILES)

# Upload examples files
upload_examples: $(EXAMPLES_FILES) prepare venv copy_example upload_webide

copy_example:
	@cp $(EXAMPLE_FILES) $(DIST)/http


# Upload httpserver lua files (init and server module)
upload_server: prepare patchserver venv httpserver/Makefile
	@make -C httpserver upload_server

# Upload all
upload_all: upload_server upload_webide upload_examples
