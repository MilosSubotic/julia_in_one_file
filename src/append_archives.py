#!/usr/bin/env python
# encoding: utf-8

'''
@file: append_archives.py
@date: Sep 14, 2014

@author: Milos Subotic <milos.subotic.sm@gmail.com>
@license: MIT

@brief: Append julia root and site archives to ELF file.

@version: 3.0
Changelog:
1.0 - Initial version.
2.0 - ELF size on end of file instead of replacing magic number. Renaming.
3.0 - Renaming and multiple archives.

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
	julia_root_file_name = sys.argv[3]
	site_file_name = sys.argv[4]

	with open(output_file_name, 'wb') as of:
		# Copy ELF.
		for chunk in chunks_from_file(elf_file_name):
			of.write(chunk)

		julia_root_start = of.tell()

		# Copy archive.
		for chunk in chunks_from_file(julia_root_file_name):
			of.write(chunk)
		
		site_start = of.tell()

		# Copy archive.
		for chunk in chunks_from_file(site_file_name):
			of.write(chunk)
		
		# Write archives start at the end of file,
		# so julia_in_one_file could later find start of arhives.
		of.write(struct.pack('I', julia_root_start))
		of.write(struct.pack('I', site_start))

###############################################################################

