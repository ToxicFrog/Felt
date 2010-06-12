# Compiler and common libraries
CC=gcc
PKG_LUA=lua

# Platform dependent
RM=rm -rf
CP=cp
MKDIR=mkdir -p
DESTDIR=/usr/local
GEN=$(DESTDIR)/bin/lgob-generator
PWD=`pwd`
SED=sed
EP=chmod +x
LN=ln -s
OS=OS_UNIX
