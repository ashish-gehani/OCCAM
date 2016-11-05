#
# Top-level OCCAM Makefile
#
# To use: 
#  set LLVM_HOME to the install directory of LLVM
#  set OCCAM_HOME to where you want the Occam tools to be installed
#
# Then type gmake, followed gmake install (or sudo -E gmake install).
#

# export LLVM_HOME=/usr/local
# export OCCAM_HOME=~/occam

ifneq (,)
This Makefile requires GNU Make.
endif

export LDFLAGS=-L/usr/local/lib

# subdirectories in OCCAM_HOME

export OCCAM_ROOT = $(OCCAM_HOME)/root
export OCCAM_BIN = $(OCCAM_HOME)/bin
export OCCAM_PBIN = $(OCCAM_HOME)/pbin
export OCCAM_LIB = $(OCCAM_HOME)/lib

MKDIR_P = mkdir -p
INSTALL = install
# MAKE = gmake

#
# Build the libprevirt.so in src
# and the config.py file in tools/occam/occam
#
all: check-occam-home
	$(MAKE) -C src all
	$(MAKE) -C tools/occam config

#
# Install all tools needed by occam in INSTALL_DIR
# (may need sudo -E for this to work)
#
install: check-occam-home install-previrt install-occam install-tools

install-dirs: check-occam-home
	$(MKDIR_P) $(OCCAM_BIN)
	$(MKDIR_P) $(OCCAM_PBIN)
	$(MKDIR_P) $(OCCAM_ROOT)
	$(MKDIR_P) $(OCCAM_LIB)

install-previrt: install-dirs
	$(MAKE) -C src install

install-occam: install-dirs
	$(MAKE) -C tools/occam install

install-tools: check-occam-home
	$(INSTALL) -m 775 tools/bin/clean-all.sh $(OCCAM_BIN)

#
# Remove the INSTALL_DIR directory and everything in it
# (may need sudo for this)
#
uninstall: check-occam-home
	$(MAKE) -C tools/occam uninstall

#
# Delete the object files from src
#
clean: 
	$(MAKE) -C src clean
	$(MAKE) -C tools/occam clean

#
# Check for OCCAM_HOME
#
check-occam-home:
ifeq ($(OCCAM_HOME),)
	$(error OCCAM_HOME is undefined)
endif


