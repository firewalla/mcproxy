#!/bin/bash
# Reproducible build: dynamic link + strip + UPX --best (mirrors the
# firerouter smcrouted binaries' build recipe). Run from this directory
# on the target platform (one run per arch/codename).
#
# qmake/Qt is NOT required despite mcproxy.pro being a qmake project
# file: it sets `CONFIG -= qt`, and a plain g++ build of all non-tester
# .cpp files (no Qt headers, no Qt libs, no qmake-generated mkspec
# include path) produces an identical, working binary -- verified on
# Gold v1 (bionic, x86_64). Skips installing qt5-qmake (~5MB, pulls in
# qtchooser) on boxes with small overlay root partitions.

set -e

g++ -std=c++11 -O2 -o mcproxy $(find src -name '*.cpp' ! -path '*/tester/*') -I. -lpthread

cp mcproxy mcproxy_upx
strip mcproxy_upx
upx --best mcproxy_upx

# Reference sizes from the Gold v1 verification build:
#   573888 (unstripped) -> 461088 (stripped) -> 160636 (upx --best)
# `./mcproxy_upx -h` must print "Mcproxy version 1.1.0" + usage after
# packing -- confirms shared libs (libpthread/libstdc++/libgcc_s/libc/
# libm) still resolve correctly at runtime post-UPX.
