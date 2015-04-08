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

#default: ${JULIA_IN_ONE_FILE}
default: kgb${EXE}

kgb${EXE}: kgb.o
	${CXX} -static-libgcc -static-libstdc++ -o $@ $^


test: kgb${EXE}
	rm -rf julia_root.kgb unpack
	./kgb -0 julia_root.kgb julia_root/lib/libjulia.so julia_root/lib/libblas.so
	mkdir -p unpack #/julia_root/lib
	cd unpack && ../kgb ../julia_root.kgb

${JULIA_IN_ONE_FILE}: julia_in_one_file.elf julia_root.tar.bz2 \
		append_tarball.py 
	./append_tarball.py $@
	chmod a+x $@

julia_in_one_file.elf: julia_in_one_file.o
	${CXX} -static-libgcc -static-libstdc++ -o $@ $^

clean:
	make -C julia cleanall
	rm -f *.o *.elf

distclean:
	rm -rf julia julia_root
	rm -f *.o *.elf
	rm -f julia_root.tar.bz2
	#rm -f julia_in_one_file

windows:
	# http://www.7-zip.org/download.html
	# http://www.python.org/download/releases
	# http://downloads.sourceforge.net/project/mingwbuilds/mingw-builds-install/mingw-builds-install.exe
	# 		- 4.8.1, x64, win32, seh, 5
	#		- C:\mingw-builds\x64-4.8.1-win32-seh-rev5
	# http://sourceforge.net/projects/msys2/files/Base/x86_64/msys2-x86_64-20140910.exe
	# 		- MSYS2 Shell
	#		- pacman-key --init
	#		- pacman -Syu
	#		- Restart shell
	#		- pacman -S diffutils git m4 make patch tar msys/openssh unzip
	#		- Restart shell
	#		- echo "mount C:/Python27 /python" >> ~/.bashrc
	#		- echo "mount C:/mingw-builds/x64-4.8.1-win32-seh-rev5/mingw64 /mingw" >> ~/.bashrc
	#		- echo "export PATH=/usr/local/bin:/usr/bin:/opt/bin:/mingw/bin:/python" >> ~/.bashrc
	#		- Restart shell
	
###############################################################################

