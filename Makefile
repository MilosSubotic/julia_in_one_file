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
# 2.0 - Reorganization and KGB archiving.
#
###############################################################################
# Main targets.

# TODO More.
.PHONY: default julia_in_one_file clean

default: julia_in_one_file

###############################################################################
# Private vars and defs.

define backup
	zip -9r $(1).backup-$$(date +%F-%T | sed 's/:/-/g').zip $(2)
endef

###############################################################################
# Prepare.

dependecies:
	sudo apt-get install make g++ gfortran

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
	echo '		- echo "mount C:/Python27 /python" >> ~/.bashrc                                                        '
	echo '		- echo "mount C:/mingw-builds/x64-4.8.1-win32-seh-rev5/mingw64 /mingw" >> ~/.bashrc                    '
	echo '		- echo "export PATH=/usr/local/bin:/usr/bin:/opt/bin:/mingw/bin:/python" >> ~/.bashrc                  '
	echo '		- Restart shell                                                                                        '
	
###############################################################################
# Rules.

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
	make backup_site

backup_site:
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

# TODO For debug.
julia_in_one_file:
	make -C src/

###############################################################################
# House keeping.

clean:
	make -C julia cleanall
	rm -f *.o *.elf

distclean:
	rm -rf julia julia_root
	rm -f *.o *.elf
	rm -f julia_root.tar.bz2
	#rm -f julia_in_one_file

###############################################################################

