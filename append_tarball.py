#!/usr/bin/env python
# encoding: utf-8

'''
@file: append_tarball.py
@date: Sep 14, 2014

@author: Milos Subotic <milos.subotic.sm@gmail.com>
@license: MIT

@brief: Append julia tarball to ELF file.

@version: 1.0
Changelog:
1.0 - Initial version.

'''

###############################################################################

from __future__ import print_function
from __future__ import division

import os
import sys
import fnmatch
import fileinput
from math import ceil

###############################################################################

chunk_size = 4096

def chunks_from_file(filename):
	with open(filename, 'rb') as f:
		while True:
			chunk = f.read(chunk_size)
			if chunk:
				yield chunk
			else:
				break

if __name__ == '__main__':
	output_file_name = sys.argv[1]

	tarball = 'julia_root.tar.bz2'

	elf_size = os.path.getsize('julia_in_one_file.elf')
	size = int(ceil(elf_size / chunk_size)) * chunk_size
	fill_up = size - elf_size
	print(elf_size)
	print(fill_up)
	print(size)
	l = [
		size & 0xff,
		(size >> 8) & 0xff,
		(size >> 16) & 0xff,
		(size >> 24) & 0xff,
		0,
		0,
		0,
		0
	]
	replacement = ''.join(map(chr, l))
	with open(output_file_name, 'wb') as of:
		
		# Check for magic number.
		found_count = 0
		for chunk in chunks_from_file('julia_in_one_file.elf'):
			if chunk.find('\xef\xbe\xad\xde\xef\xbe\xad\xde') != -1:
				found_count += 1
				if found_count > 1:
					raise RuntimeError('0xdeadbeefdeadbeef occures multiple '
						'times in julia_in_one_file.elf')
		if found_count == 0:
			raise RuntimeError("0xdeadbeefdeadbeef doesn't occure in "
						'julia_in_one_file.elf')

		# Replace magic with ELF size ei. tarball offset.
		for chunk in chunks_from_file('julia_in_one_file.elf'):
			chunk = chunk.replace(
				'\xef\xbe\xad\xde\xef\xbe\xad\xde', 
				replacement
			)
			of.write(chunk)

		# Fill up to chunk size.
		of.write(' ' * fill_up)

		# Copy tarball.
		for chunk in chunks_from_file(tarball):
			of.write(chunk)
		

###############################################################################

