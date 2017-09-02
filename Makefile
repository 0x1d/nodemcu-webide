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
SRC_HTML_FILES := $(wildcard src/*.html)
SRC_JS_FILES := $(wildcard src/*.js)
SRC_ICO_FILES := $(wildcard src/*.ico)

EXAMPLE_FILES := $(wildcard examples/*.html) $(wildcard examples/*.lua)

DIST := dist
DIST_FILES = $(wildcard $(DIST)/*.gz) $(wildcard $(DIST)/*.lua)

# Print usage
usage:
	@echo "make upload FILE:=<file>  to upload a specific file (i.e make upload FILE:=init.lua)"
	@echo "make upload_webide        to upload webide"
	@echo "make upload_webide        to upload examples"
	@echo "make upload_server        to upload the server code and init.lua"
	@echo "make upload_all           to upload all"
	@echo $(TEST)

prepare: httpserver/Makefile patchserver

# make sure that the submodules are fetch
httpserver/Makefile:
	@echo Preparing submodules...
	@git submodule init
	@git submodule update
	
# Patch httpserver makefile for upload and init
patchserver: httpserver/makefile.patched httpserver/init.patched

httpserver/makefile.patched: patchs/httpserver_makefile.patch httpserver/Makefile
	@echo Patching httpserver makefile...
	@if [ -e $@ ]; then patch -p1 -R < $?; fi
	@patch -p1 < $?
	@touch ${@}
	
httpserver/init.patched: patchs/httpserver_init.patch httpserver/httpserver-compile.lua
	@echo Patching httpserver scripts...
	@if [ -e $@ ]; then patch -p1 -R < $?; fi
	@patch -p1 < $?
	@touch ${@}
	
httpserver/httpserver-start.lua:
	@echo Replace httpserver init.lua by ${@}
	@mv httpserver/init.lua ${@}


install: compress copy_lua
	
# Compress files
compress: compress_html compress_js compress_ico

compress_html: $(SRC_HTML_FILES)
	@echo Compression HTML files
	@cp $^ $(DIST)/
	@gzip -9 -f $(DIST)/*.html
	
compress_js: $(SRC_JS_FILES)
	@echo Compression JS files
	cp $^ $(DIST)/
	gzip -9 -f $(DIST)/*.js
	
compress_ico: $(SRC_ICO_FILES)
	@echo Compression ICO files
	cp $^ $(DIST)/
	gzip -9 -f $(DIST)/*.ico

copy_lua: $(SRC_LUA_FILES)
	cp $^ $(DIST)/
	
venv: prepare venv/bin/activate
venv/bin/activate: uploader/test_requirements.txt
	@test -d venv || virtualenv venv --python=python3
	@venv/bin/pip install -Ur $<
	@touch venv/bin/activate

# Upload one files only
upload: prepare venv
	@$(PYTHON) $(NODEMCU-COMMAND) $(FILE)

# Upload webide
upload_webide: $(DIST_FILES) prepare venv install
	@$(PYTHON) $(NODEMCU-COMMAND) $(foreach f, $^, $(f))

# Upload examples files
upload_examples: $(EXAMPLES_FILES) prepare venv
	@$(PYTHON) $(NODEMCU-COMMAND) $(foreach f, $^, $(f))
	
	
# Upload httpserver lua files (init and server module)
upload_server: prepare patchserver venv httpserver/Makefile
	@make -C httpserver upload_server

# Upload all
upload_all: upload_server upload_webide upload_examples
