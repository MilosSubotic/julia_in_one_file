#
###############################################################################
# @file config.mk
# @date May 1, 2015
#
# @author Milos Subotic <milos.subotic.sm@gmail.com>
# @license MIT
#
# @brief Makfiles configuration for for Julia in one file.
#
# @version: 1.0
# Changelog:
# 1.0 - Initial version.
#
###############################################################################
# User vars.

#JULIA_TARBALL=tarballs/julia-0.4.0-dev_1c131acc50.tar.gz
#JULIA_TARBALL=tarballs/julia-0.4.0-dev_195bd01cfb-full.tar.gz
JULIA_TARBALL=tarballs/julia-0.4.0-dev_eb5da264e8-full.tar.gz

# A10
#JULIA_CPU_TARGET=bdver2
#OPENBLAS_TARGET_ARCH=BULLDOZER

# Phenom
#JULIA_CPU_TARGET=amdfam10
#OPENBLAS_TARGET_ARCH=BARCELONA

# Dell
JULIA_CPU_TARGET=core2
OPENBLAS_TARGET_ARCH=CORE2

# Comment out JULIA_ROOT and SITE to use newest.
#JULIA_ROOT=
#SITE=

###############################################################################

