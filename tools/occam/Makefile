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
	$(INSTALL) -m 775 occam2 ${OCCAM_BIN}
	$(INSTALL) -m 775 occam_environment ${OCCAM_BIN}/occam
	for x in clean enforce interface peval rewrite show simplify slice build; do \
	  rm -f ${OCCAM_BIN}/occam-$$x; \
	  $(LN_S) occam2 ${OCCAM_BIN}/occam-$$x; \
	done
	for x in clang clang++ clang-cpp ar ranlib ld install cp mv chmod ln rm unlink; do \
	  rm -f ${OCCAM_BIN}/$$x; \
	  $(LN_S) occam2 ${OCCAM_BIN}/$$x; \
	done
	for x in make sed cat touch mkdir tr sort nawk grep expr ls uname; do \
	  rm -f ${OCCAM_PBIN}/$$x; \
	  $(LN_S) ${OCCAM_BIN}/occam2 ${OCCAM_PBIN}/$$x; \
	done
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
