#!/usr/bin/env python
# encoding: utf-8

'''
@file: create_version_header.py
@date: May 1, 2015

@author: Milos Subotic <milos.subotic.sm@gmail.com>
@license: MIT

@brief: Create version header for julia_in_one_file.

@version: 1.0
Changelog:
1.0 - Initial version.

'''

###############################################################################

from __future__ import print_function

import os
import sys
import re

###############################################################################

if __name__ == '__main__':
	julia_root = os.path.basename(sys.argv[1])
	site = os.path.basename(sys.argv[2])

	m = re.match(r'julia_root-((\d+)-(\d+)-(\d+)-(\d+)-(\d+)-(\d+))-(\w+)-(\w+)-(.*).zip', julia_root)	
	build_date = m.group(1)
	build_place = m.group(8)
	build_platform = m.group(9)
	julia_ver = m.group(10)

	m = re.match(r'site-((\d+)-(\d+)-(\d+)-(\d+)-(\d+)-(\d+)).zip', site)
	site_date = m.group(1)

	with open('version.h', 'w') as f:
		f.write('''// Do NOT change this file by hands, it is generated!

#ifndef VERSION_H
#define VERSION_H

#define BUILD_DATE "{build_date}"
#define BUILD_PLACE "{build_place}"
#define BUILD_PLATFORM "{build_platform}"
#define JULIA_VER "{julia_ver}"
#define SITE_DATE "{site_date}"

#endif // VERSION_H

'''.format(
			build_date = build_date,
			build_place = build_place,
			build_platform = build_platform,
			julia_ver = julia_ver,
			site_date = site_date
		))

###############################################################################

