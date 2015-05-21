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

.PHONY: default download download_site dependecies windows
.PHONY: build_root julia_in_one_file all install clean

default: all

###############################################################################
# Private vars and defs.

include config/config.mk
include src/common.mk
	
###############################################################################
# Download.

download:
	mkdir -p build/download/
	cd build/download/ && git clone git://github.com/JuliaLang/julia.git
	cd build/download/julia && make source-dist
	mv build/download/julia/julia-0.4.0-dev_*.tar.gz tarballs/
	rm -rf build/download/

download_site:
	mkdir -p build/site/
	JULIA_PKGDIR=build/site julia config/update_repo.jl
	-find build/site/ -name .cache -exec rm -rf {} \;
	-find build/site/ -name .git -exec rm -rf {} \;
	cd build && zip -9r ../backup/site-\
$(shell date +%F-%T | sed 's/:/-/g').zip site/

###############################################################################
# Prepare.

dependecies:
	sudo apt-get install bzip2 gcc gfortran git g++ make m4 ncurses-dev

windows:
	echo 'http://www.7-zip.org/download.html                                                                           '
	echo 'http://www.python.org/download/releases/                                                                     '
	echo 'http://www.cmake.org/download/                                                                               '
	echo 'http://downloads.sourceforge.net/project/mingwbuilds/mingw-builds-install/mingw-builds-install.exe           '
	echo '		- 4.8.1, x64, win32, seh, 5                                                                            '
	echo '		- C:\mingw-builds\x64-4.8.1-win32-seh-rev5                                                             '
	echo 'http://sourceforge.net/projects/msys2/files/Base/x86_64/msys2-x86_64-20140910.exe                            '
	echo '		- MSYS2 Shell                                                                                          '
	echo '		- pacman-key --init                                                                                    '
	echo '		- pacman -Syu                                                                                          '
	echo '		- Restart shell                                                                                        '
	echo '		- pacman -S diffutils git m4 make patch tar msys/openssh unzip '                                       '
	echo '		- Restart shell                                                                                        '
	echo '		- echo "mount C:/Python27/python" >> ~/.bashrc                                                         '
	echo '		- echo "mount C:/Program\ Files\ \(x86\)/CMake /cmake" >> ~/.bashrc                                    '
	echo '		- echo "mount C:/mingw-builds/x64-4.8.1-win32-seh-rev5/mingw64 /mingw" >> ~/.bashrc                    '
	echo '		- echo "export PATH=/usr/local/bin:/usr/bin:/opt/bin:/mingw/bin:/python:/cmake/bin:\$PATH" >> ~/.bashrc'
	echo '		- Restart shell                                                                                        '

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


U=build/julia/Make.user
build/status/built: build/status/unpacked
	echo "prefix=${PWD}/build/julia_root"               >  ${U}
	echo "JULIA_CPU_TARGET=${JULIA_CPU_TARGET}"         >> ${U}
	echo "OPENBLAS_TARGET_ARCH=${OPENBLAS_TARGET_ARCH}" >> ${U}
	make install -j6 -C build/julia/
	touch $@

B=${PWD}/build/julia_root/share/julia/base/
L=${PWD}/build/julia_root/lib/julia/
J=${PWD}/build/julia/usr/bin/julia
opt:
	cd ${B} && echo 'Base.require("PyPlot.jl")' > userimg.jl
	cd ${B} && ${J} -C core2 -b ${L}/sys0 sysimg.jl
	cd ${B} && ${J} -C core2 -b ${L}/sys -J ${L}/sys0.ji

build/status/cleanup: build/status/built
	rm -f julia_root/bin/julia-debug
	rm -f julia_root/lib/julia/libjulia-debug.so
	rm -f julia_root/bin/julia-debug.exe
	rm -f julia_root/bin/libjulia-debug.dll
	rm -rf julia_root/share/julia/test/
	touch $@

build/status/packed_root: build/status/cleanup
	rm -f build/julia_root*.zip
	cd build && zip -9r ../backup/julia_root-\
$(shell date +%F-%T | sed 's/:/-/g')-${PLACE_PLATFORM_VER}.zip julia_root/
	touch $@

build_root: build/status/packed_root

julia_in_one_file:
	make -C src/ all

all:
	make build_root
	make julia_in_one_file

install:
	make -C src/ install
	rm -rf /tmp/julia_root

###############################################################################
# House keeping.

clean:
	make -C src/ clean
	rm -rf build/

dist: clean
	cd ../ && zip -9r \
		julia_in_one_file-$$(date +%F-%T | sed 's/:/-/g').zip julia_in_one_file

###############################################################################

