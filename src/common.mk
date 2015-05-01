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
# Private vars and defs.

JULIA_VER=$(patsubst tarballs/julia-%.tar.gz,%,${JULIA_TARBALL})
BUILD_PLATFORM=$(shell uname -s)
BUILD_PLACE=$(shell uname -n)
PLACE_PLATFORM_VER=${BUILD_PLACE}-${BUILD_PLATFORM}-${JULIA_VER}

define backup
	zip -9r $(1)-$$(date +%F-%T | sed 's/:/-/g').zip $(2)
endef

###############################################################################

