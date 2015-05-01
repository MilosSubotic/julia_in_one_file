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
# Private vars.

include ../common.mk

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
LIBS=-lz -ldl

###############################################################################

.PHONY: default clean 

default: julia_in_one_file${EXE}

###############################################################################

julia_in_one_file.elf: julia_in_one_file.o junzip.o
	${CXX} -static-libgcc -static-libstdc++ -o $@ $^ ${LDFLAGS} ${LIBS}

# TODO Better selection of root and site.
julia_in_one_file${EXE}: julia_in_one_file.elf ../backup/julia_root*.zip ../backup/site*.zip
	./append_archives.py $@ $^
	chmod a+x $@

test: julia_in_one_file${EXE}
	./julia_in_one_file${EXE}

###############################################################################

clean: 
	rm -rf julia_in_one_file${EXE} *.o *.elf
	
###############################################################################

