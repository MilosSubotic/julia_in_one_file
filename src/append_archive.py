#!/usr/bin/env python
# encoding: utf-8

'''
@file: append_archive.py
@date: Sep 14, 2014

@author: Milos Subotic <milos.subotic.sm@gmail.com>
@license: MIT

@brief: Append julia root archive to ELF file.

@version: 2.0
Changelog:
1.0 - Initial version.
2.0 - ELF size on end of file instead of replacing magic number. Renaming.

'''

###############################################################################

from __future__ import print_function

import os
import sys
import struct

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
	elf_file_name = sys.argv[2]
	archive_file_name = sys.argv[3]

	elf_size = os.path.getsize(elf_file_name)

	with open(output_file_name, 'wb') as of:
		# Copy ELF.
		for chunk in chunks_from_file(elf_file_name):
			of.write(chunk)

		# Copy archive.
		for chunk in chunks_from_file(archive_file_name):
			of.write(chunk)
		
		# Write ELF size at the end of file,
		# so julia_in_one_file could later find start of arhive.
		of.write(struct.pack('I', elf_size))

###############################################################################

