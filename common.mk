#
###############################################################################
# @file common.mk
# @date May 1, 2015
#
# @author Milos Subotic <milos.subotic.sm@gmail.com>
# @license MIT
#
# @brief Common build stuff for Julia in one file Makfiles.
#
# @version: 1.0
# Changelog:
# 1.0 - Initial version.
#
###############################################################################
# User vars.

# TODO Cannot find newest by name because it don't have date in name.
#JULIA_TARBALL=$(shell ls -w1 tarballs/julia-*.tar.gz | tail -n 1)
JULIA_TARBALL=tarballs/julia-0.4.0-dev_195bd01cfb-full.tar.gz

###############################################################################
# Private vars.

JULIA_VER=$(patsubst tarballs/julia-%.tar.gz,%,${JULIA_TARBALL})
BUILD_PLATFORM=$(shell uname -s)
BUILD_PLACE=$(shell uname -n)

#define newest_julia_root

###############################################################################

