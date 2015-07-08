# Fix this later (using configure)
# NOTE: python 2.7 is required
INSTALL = /usr/bin/install
MKDIR_P = mkdir -p
LN_S = ln -s
PYTHON = python
PYLINT = pylint

all: config

config:
	$(PYTHON) occam/genconfig.py > occam/config.py
	$(PYTHON) setup.py build

clean:
	rm -rf occam/config.py build

install: check-occam-bin config
	$(INSTALL) -m 775 occam_start ${OCCAM_BIN}/occam
		
	if test `whoami` != "root" ; \
	then \
	  sudo -E $(PYTHON) setup.py install; \
	else \
	  $(PYTHON) setup.py install; \
	fi

uninstall: check-occam-bin
	rm -rf ${OCCAM_BIN} ${OCCAM_PBIN}

lint:
	@ $(PYLINT) -E occam/*.py occam/targets/*.py

#
# Check for OCCAM_BIN
#
check-occam-bin:
ifeq ($(OCCAM_BIN),)
	$(error OCCAM_BIN is undefined)
endif
