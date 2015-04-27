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

CPPFLAGS=-Ikgb/

###############################################################################

.PHONY: default clean 

default: julia_in_one_file${EXE}

###############################################################################

julia_in_one_file.elf: julia_in_one_file.o kgb/kgb.o
	${CXX} -static-libgcc -static-libstdc++ -o $@ $^

julia_in_one_file${EXE}: julia_in_one_file.elf ./julia_root.kgb
	./append_archive.py $@ $^
	chmod a+x $@

kgb/kgb.o:
	make -C kgb/

test: julia_in_one_file${EXE}
	./julia_in_one_file${EXE}

###############################################################################

clean: 
	rm -rf julia_in_one_file${EXE} *.o *.elf
	make -C kgb/
	
###############################################################################

