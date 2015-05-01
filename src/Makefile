#
###############################################################################
# @file Makefile
# @date Apr 7, 2015
#
# @author Milos Subotic <milos.subotic.sm@gmail.com>
# @license MIT
#
# @brief Julia in one file command.
#
# @version: 1.0
# Changelog:
# 1.0 - Initial version.
#
###############################################################################

.PHONY: default all install clean 

default: all

###############################################################################
# Private vars.

include ../config/config.mk
include common.mk


BUILD_OS=$(shell uname)
ifneq (,$(findstring MINGW,$(BUILD_OS)))
	BUILD_OS=WINNT
endif
ifneq (,$(findstring MSYS,$(BUILD_OS)))
	BUILD_OS=WINNT
endif

ifeq (${BUILD_OS},WINNT)
	EXE=.exe
else
	EXE=
endif


CXXFLAGS=-fPIC -O3
# TODO Static zlib.
LIBS=-lz

ifdef JULIA_ROOT
	JULIA_ROOT:=echo ../${JULIA_ROOT}
else
	JULIA_ROOT:=ls -w1 ../backup/julia_root-*-${PLACE_PLATFORM_VER}.zip | tail -n 1
endif

ifdef SITE
	SITE:=echo ../${JULIA_ROOT}
else
	SITE:=ls -w1 ../backup/site.backup-*.zip | tail -n 1
endif

###############################################################################

generate_version.h:
	./create_version_header.py $$(${JULIA_ROOT}) $$(${SITE})

julia_in_one_file.o: generate_version.h

julia_in_one_file.elf: julia_in_one_file.o junzip.o
	${CXX} -static-libgcc -static-libstdc++ -o $@ $^ ${LDFLAGS} ${LIBS}

# TODO Better selection of root and site.
julia_in_one_file${EXE}: julia_in_one_file.elf
	./append_archives.py $@ julia_in_one_file.elf $$(${JULIA_ROOT}) $$(${SITE})
	chmod a+x $@

all: julia_in_one_file${EXE}
	$(call backup,../backup/julia_in_one_file${EXE},julia_in_one_file${EXE})

install: all
	mkdir -p ${HOME}/local/bin/
	cp -v julia_in_one_file${EXE} ${HOME}/local/bin/julia${EXE}

###############################################################################

clean: 
	rm -rf julia_in_one_file${EXE} *.o *.elf version.h
	
###############################################################################

