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

default: julia_in_one_file

download:
	git clone git://github.com/JuliaLang/julia.git
	cd julia && make source-dist
	mv julia/julia-0.4.0-dev_*.tar.gz .
	# Backup if there is backup script.
	if ! test -z $$(which backup); \
	then \
		backup -z julia; \
	fi

unpack_git:
	# Newest backup
	unzip $(shell ls -w1 julia.backup-*.zip | tail -n 1)
	cd julia && ../fix_git.py

unpack_tarball:
	 # Newest tarball, download if there is no one.
	TARBALL=$(shell ls -w1 julia-*.tar.gz | tail -n 1); \
	if test -z $$TARBALL; \
	then \
		make download; \
	else \
		tar xfv $$TARBALL; \
	fi

dependecies:
	sudo apt-get install make g++ gfortran

build: unpack_tarball
	rm -f julia/Make.user
	echo "prefix=${PWD}/julia_root" >> julia/Make.user
	time make -C julia -j4
	make -C julia install

julia_root.tar.bz2: build
	rm -f julia_root/bin/julia-debug
	rm -f julia_root/lib/julia/libjulia-debug.so
	rm -rf julia_root/share/julia/test/
	tar cfvj julia_root.tar.bz2 julia_root

julia_in_one_file: julia_in_one_file.elf append_tarball.py julia_root.tar.bz2
	./append_tarball.py
	chmod a+x $@
	rm -f *.o *.elf
	rm julia_root.tar.bz2

julia_in_one_file.elf: julia_in_one_file.o
	${CXX} -o $@ $^
	rm -f $^

clean:
	make -C julia cleanall
	rm -f *.o *.elf

distclean:
	rm -rf julia julia_root
	rm -f *.o *.elf
	#rm -f julia_in_one_file

###############################################################################

