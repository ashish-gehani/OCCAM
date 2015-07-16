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
# export OCCAM_HOME=/home/moore/occam

#- Edited: Hashim Sharif (hashim.sharif@sri.com)
#- Added LLPE installation


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
MAKE = gmake


#
# Build the libprevirt.so in src
# and the config.py file in tools/occam/occam
#
all: 	
	$(MAKE) -C src all
	$(MAKE) -C tools/occam config
	
	if [ ! -d "llpe/build" ]; then \
	  	git clone https://github.com/smowton/llpe.git; mkdir llpe/build; fi

	cp LLPE/CMakeLists.txt llpe/llpe/driver/ 
	cp LLPE/Integrator.cpp llpe/llpe/driver/
	cp LLPE/Eval.cpp llpe/llpe/main/ 
	cp LLPE/VFSCallModRef.cpp llpe/llpe/main/ 		
	cp LLPE/PartialLoadForward.cpp llpe/llpe/main/ 		 		
	cd llpe/build && cmake -D CMAKE_BUILD_TYPE:STRING=RelWithDebInfo ../llpe && gmake
	
#
# Install all tools needed by occam in INSTALL_DIR
# (may need sudo -E for this to work)
#
install: install-previrt install-occam install-tools install-llpe

install-dirs:
	$(MKDIR_P) $(OCCAM_BIN)
	$(MKDIR_P) $(OCCAM_PBIN)
	$(MKDIR_P) $(OCCAM_ROOT)
	$(MKDIR_P) $(OCCAM_LIB)

install-previrt: install-dirs
	$(MAKE) -C src install

install-occam: install-dirs
	$(MAKE) -C tools/occam install

install-tools:
	$(INSTALL) -m 775 tools/bin/clean-all.sh $(OCCAM_BIN)

install-llpe:
	mv llpe/build/main/libLLVMLLPEMain.so $(OCCAM_HOME)/lib
	mv llpe/build/driver/libLLVMLLPEDriver.so $(OCCAM_HOME)/lib
	
#
# Remove the INSTALL_DIR directory and everything in it
# (may need sudo for this)
#
uninstall:
	$(MAKE) -C tools/occam uninstall

#
# Delete the object files from src
#
clean:
	$(MAKE) -C src clean
	$(MAKE) -C tools/occam clean
