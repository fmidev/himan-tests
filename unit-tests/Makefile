PROG = himan

SCONS_FLAGS=-j 4

# How to install

INSTALL_PROG = install -m 755

# rpm variables

CWP = $(shell pwd)
BIN = $(shell basename $(CWP))

rpmsourcedir = /tmp/$(shell whoami)/rpmbuild

INSTALL_TARGET = /usr/bin

# The rules

all release:
	scons-3 $(SCONS_FLAGS)
debug:
	scons-3 $(SCONS_FLAGS) --debug-build || exit 1
clean:
	scons-3 -c ; scons-3 --debug-build -c ; rm -f *~ source/*~ include/*~
