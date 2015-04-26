#
###############################################################################
# @file Makefile
# @date Apr 26, 2015
#
# @author Milos Subotic <milos.subotic.sm@gmail.com>
# @license MIT
#
# @brief KGB archiver library and command line tool.
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

.PHONY: default clean 

default: kgb${EXE}

###############################################################################

kgb${EXE}: kgb.o kgb_main.o
	${CXX} -static-libgcc -static-libstdc++ -o $@ $^

###############################################################################

clean: 
	rm -rf kgb${EXE} *.o
	
###############################################################################

