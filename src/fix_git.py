#!/usr/bin/env python
# encoding: utf-8

'''
@file: fix_git.py
@date: Sep 13, 2014

@author: Milos Subotic <milos.subotic.sm@gmail.com>
@license: MIT

@brief: Fix git submodules paths.

@version: 1.0
Changelog:
1.0 - Initial version.

'''

###############################################################################

from __future__ import print_function

import os
import sys
import fnmatch
import fileinput

###############################################################################

def recursive_glob(pattern, directory = '.'):
	for root, dirs, files in os.walk(directory, followlinks = True):
		for f in files:
			if fnmatch.fnmatch(f, pattern):
				yield os.path.join(root, f)
		for d in dirs:
			if fnmatch.fnmatch(d + '/', pattern):
				yield os.path.join(root, d)

if __name__ == '__main__':
	# Find all .git files, which reside in submodule dirs.
	for git_file in recursive_glob('.git'):

		git_dir = ''
		module_path = ''

		# Change project path of git dir and save them for later.
		for line in fileinput.input(git_file, inplace = True):
			if line.startswith('gitdir:'):
				git_dir = line.replace('gitdir: ', '')
				git_dir = git_dir[:-1] # Remove \n
				old_project_path, module_path = git_dir.split('/.git/modules/')
				git_dir = '{cwd}/.git/modules/{module_path}'.format(
					cwd = os.getcwd(),
					module_path = module_path
				)
				print('gitdir: ' + git_dir,	end = '\n')
			else:				
				print(line, end = '')	

		# Change worktree in config file.
		config_file = os.path.join(git_dir, 'config')
		for line in fileinput.input(config_file, inplace = True):
			if line.startswith('	worktree = '):
				worktree = line.replace('	worktree = ', '')
				worktree = worktree[:-1] # Remove \n
				worktree = '{cwd}/{module_path}'.format(
					cwd = os.getcwd(),
					module_path = module_path
				)
				print('	worktree = ' + worktree,	end = '\n')	
			else:
				print(line, end = '')

###############################################################################

