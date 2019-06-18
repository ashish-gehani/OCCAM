THIS_DIR= $(shell pwd)

PREFIX ?=install

LLVMCC ?=gclang
LLVMCXX ?= gclang++
LLVMGET=get-bc

MEM=memcached
MEM_VERSION=1.4.25
MEM_TAR=${MEM}-${MEM_VERSION}.tar.gz
MEM_URL=https://memcached.org/files/${MEM_TAR}
MEM_INSTALL=${THIS_DIR}/${PREFIX}/${MEM}

LIBEVENT=libevent
LIBEVENT_INSTALL=${THIS_DIR}/${PREFIX}/${LIBEVENT}

bitcode: ${MEM}.bc

${MEM_TAR}:
	wget ${MEM_URL}


${LIBEVENT_INSTALL}:
	make -f ./Makefile_libevent

${MEM_INSTALL}/bin/${MEM}: ${MEM_TAR} ${LIBEVENT_INSTALL}
	tar -xvzf ${MEM_TAR}
	cd ${MEM}-${MEM_VERSION}; \
	CC=${LLVMCC} ./configure --prefix=${MEM_INSTALL} --with-libevent=${LIBEVENT_INSTALL}; \
	make; make install

${MEM}.bc: ${MEM_INSTALL}/bin/${MEM}
	${LLVMGET} ${MEM_INSTALL}/bin/${MEM}
	mv ${MEM_INSTALL}/bin/${MEM}.bc .

clean:
	rm -rf ${MEM}-${MEM_VERSION} OCCAM ${MEM_TAR} ${MEM}.bc
	make -f Makefile_libevent clean
	rm -f memcached_orig memcached_slashed memcached.manifest

distclean:
	make clean
	rm -rf install
	rm -rf slash
