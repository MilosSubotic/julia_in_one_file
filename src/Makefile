#
###############################################################################
# @file Makefile
# @date Apr 7, 2015
#
# @author Milos Subotic <milos.subotic.sm@gmail.com>
# @license MIT
#
# @brief Julia in one file, source building.
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

###############################################################################

.PHONY: default 

default: julia_in_one_file${EXE}


kgb${EXE}: kgb.o kgb_main.o
	${CXX} -static-libgcc -static-libstdc++ -o $@ $^


julia_in_one_file.elf: julia_in_one_file.o kgb.o
	${CXX} -static-libgcc -static-libstdc++ -o $@ $^

julia_in_one_file${EXE}: julia_in_one_file.elf ./julia_root.kgb
	./append_archive.py $@ $^
	chmod a+x $@

###############################################################################
# Old.

test: kgb${EXE}
	rm -rf julia_root.kgb unpack
	./kgb -0 julia_root.kgb julia_root/
	mkdir -p unpack
	cd unpack && ../kgb ../julia_root.kgb


	
###############################################################################

