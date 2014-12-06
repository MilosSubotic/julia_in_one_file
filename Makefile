#
###############################################################################
# @file Makefile
# @date Sep 14, 2014
#
# @author Milos Subotic <milos.subotic.sm@gmail.com>
# @license MIT
#
# @brief Julia in one file.
#
# @version: 1.0
# Changelog:
# 1.0 - Initial version.
#
###############################################################################

BUILD_OS=$(shell uname)
ifneq (,$(findstring MINGW,$(BUILD_OS)))
	BUILD_OS=WINNT
endif
ifneq (,$(findstring MSYS,$(BUILD_OS)))
	BUILD_OS=WINNT
endif

ifeq (${BUILD_OS},WINNT)
	JULIA_IN_ONE_FILE=julia_in_one_file.exe
else
	JULIA_IN_ONE_FILE=julia_in_one_file
endif

define backup
	zip -9r $(1).backup-$$(date +%F-%T | sed 's/:/-/g').zip $(2)
endef

default: ${JULIA_IN_ONE_FILE}

download:
	git clone git://github.com/JuliaLang/julia.git
	cd julia && make source-dist
	mv julia/julia-0.4.0-dev_*.tar.gz .
	$(call backup,julia,julia)

GIT_ZIP=$(shell ls -w1 julia.backup-*.zip | tail -n 1)
unpack_git: julia/.unpacked_git
julia/.unpacked_git:
	# Newest backup
ifeq (${GIT_ZIP},)
	make download
else
	unzip ${GIT_ZIP}
	cd julia && ../fix_git.py
endif
	touch $@

TARBALL=$(shell ls -w1 julia-*.tar.gz | tail -n 1)
unpack_tarball: julia/.unpacked_tarball
julia/.unpacked_tarball:
	 # Newest tarball, download if there is no one.
ifeq (${TARBALL},)
	make download
else
	tar xfv ${TARBALL}
endif
	touch $@

dependecies:
	sudo apt-get install make g++ gfortran

build: julia/.built
julia/.built: julia/.unpacked_git
	rm -f julia/Make.user
	echo "prefix=${PWD}/julia_root" >> julia/Make.user
	echo "JULIA_CPU_TARGET=core2" >> julia/Make.user
	echo "OPENBLAS_TARGET_ARCH=CORE2" >> julia/Make.user
	make -C julia install -j6
	touch $@

download_site:
	mkdir -p julia_root/share/julia/site/
	JULIA_PKGDIR=julia_root/share/julia/site julia update_repo.jl
	-find julia_root/share/julia/site/ -name .cache -exec rm -rf {} \;
	-find julia_root/share/julia/site/ -name .git -exec rm -rf {} \;
	$(call backup,site,julia_root/share/julia/site/)

SITE_ZIP=$(shell ls -w1 site.backup-*.zip | tail -n 1)
julia_root.tar.bz2: julia/.built
	rm -f julia_root/bin/julia-debug
	rm -f julia_root/lib/julia/libjulia-debug.so
	rm -f julia_root/bin/julia-debug.exe
	rm -f julia_root/bin/libjulia-debug.dll
	rm -rf julia_root/share/julia/test/
ifeq (${SITE_ZIP},)
	make download_site
else
	unzip ${SITE_ZIP} -d julia_root/share/julia/
endif
	# Pack it.
	tar cfvj julia_root.tar.bz2 julia_root

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

