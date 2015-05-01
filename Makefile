#
###############################################################################
# @file Makefile
# @date Sep 14, 2014
#
# @author Milos Subotic <milos.subotic.sm@gmail.com>
# @license MIT
#
# @brief Julia in one file, main makefile.
#
# @version: 2.0
# Changelog:
# 1.0 - Initial version.
# 2.0 - Reorganization and new code for unpacking julia root.
#
###############################################################################
# Main targets.

# TODO More.
.PHONY: default dependecies windows download build_root all install clean

default: all

###############################################################################
# Private vars and defs.

include config/config.mk
include src/common.mk

###############################################################################
# Prepare.

dependecies:
	sudo apt-get install bzip2 gcc gfortran git g++ make m4 ncurses-dev

windows:
	echo 'http://www.7-zip.org/download.html                                                                           '
	echo 'http://www.python.org/download/releases                                                                      '
	echo 'http://downloads.sourceforge.net/project/mingwbuilds/mingw-builds-install/mingw-builds-install.exe           '
	echo '		- 4.8.1, x64, win32, seh, 5                                                                            '
	echo '		- C:\mingw-builds\x64-4.8.1-win32-seh-rev5                                                             '
	echo 'http://sourceforge.net/projects/msys2/files/Base/x86_64/msys2-x86_64-20140910.exe                            '
	echo '		- MSYS2 Shell                                                                                          '
	echo '		- pacman-key --init                                                                                    '
	echo '		- pacman -Syu                                                                                          '
	echo '		- Restart shell                                                                                        '
	echo '		- pacman -S diffutils git m4 make patch tar msys/openssh unzip                                         '
	echo '		- Restart shell                                                                                        '
	echo '		- echo "mount C:/Python27/python" >> ~/.bashrc                                                        '
	echo '		- echo "mount C:/mingw-builds/x64-4.8.1-win32-seh-rev5/mingw64 /mingw" >> ~/.bashrc                    '
	echo '		- echo "export PATH=/usr/local/bin:/usr/bin:/opt/bin:/mingw/bin:/python" >> ~/.bashrc                  '
	echo '		- Restart shell                                                                                        '
	
###############################################################################
# Download rules.

download:
	git clone git://github.com/JuliaLang/julia.git
	cd julia && make source-dist
	mv julia/julia-0.4.0-dev_*.tar.gz .
	rm -rf julia

# TODO download_site

###############################################################################
# Build rules.

build/status/unpacked:
	rm -rf build/
	mkdir -p build/status
	# Unpack tarball, download if there is no one.
ifeq (${JULIA_TARBALL},)
	make download
else
	tar xfv ${JULIA_TARBALL} -C build/
endif
	touch $@


build/status/built: build/status/unpacked
	echo "prefix=${PWD}/build/julia_root" >  build/julia/Make.user
	echo "JULIA_CPU_TARGET=core2"         >> build/julia/Make.user
	echo "OPENBLAS_TARGET_ARCH=CORE2"     >> build/julia/Make.user
	make install -j6 -C build/julia/
	touch $@

build/status/cleanup: build/status/built
	rm -f julia_root/bin/julia-debug
	rm -f julia_root/lib/julia/libjulia-debug.so
	rm -f julia_root/bin/julia-debug.exe
	rm -f julia_root/bin/libjulia-debug.dll
	rm -rf julia_root/share/julia/test/
	touch $@

build/status/packed_root: build/status/cleanup
	rm -f build/julia_root*.zip
	cd build && zip -9r julia_root-$(shell date +%F-%T | sed 's/:/-/g')-\
${PLACE_PLATFORM_VER}.zip julia_root/
	mv build/julia_root*.zip backup/
	touch $@

build_root: build/status/packed_root

all:
	make -C src/ all
	mkdir -p build/status
	touch $@

install: 
	make -C src/ install

###############################################################################
# House keeping.

clean:
	make -C src/ clean
	rm -rf build/

###############################################################################

