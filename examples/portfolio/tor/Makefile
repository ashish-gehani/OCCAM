#iam 6/5/2018

THISDIR =  $(shell pwd)
OS      =  $(shell uname)
ARCH    =  $(shell uname -p)


ZLIB_VERSION = 1.2.11

OPENSSL_VERSION = 1.1.0h

LIBEVENT_VERSION = 2.1.8-stable

ZLIB_INSTALL=${THISDIR}/install/zlib

LIBEVENT_INSTALL=${THISDIR}/install/libevent

OPENSSL_INSTALL=${THISDIR}/install/openssl


TOR=tor-0.3.3.6
TOR_TARBALL=${TOR}.tar.gz
TOR_URL=https://www.torproject.org/dist/${TOR_TARBALL}
TOR_INSTALL=${THISDIR}/install/tor


LLVMCC=wllvm
LLVMGET=extract-bc

#LLVMCC=gclang
#LLVMGET=get-bc

ifeq (Darwin, $(findstring Darwin, ${OS}))

LIBEXT=dylib
CFG_FLAGS=--prefix=${TOR_INSTALL}

else

LIBEXT=so
CFG_FLAGS=--with-openssl-dir=${OPENSSL_INSTALL}  --with-libevent-dir=${LIBEVENT_INSTALL}/lib  --with-zlib-dir=${ZLIB_INSTALL}  --prefix=${TOR_INSTALL}
LDFLAGS="-L${LIBEVENT_INSTALL}/lib -L${OPENSSL_INSTALL}/lib"
CFLAGS="-I${LIBEVENT_INSTALL}/include -I${OPENSSL_INSTALL}/include -Wl,-rpath,${OPENSSL_INSTALL}/lib"

endif



BITCODE = tor.bc

all: ${BITCODE}


Makefile_zlib:
	$(error Makefile_zlib is missing but required)


${ZLIB_INSTALL}: Makefile_zlib
	ZLIB_VERSION=${ZLIB_VERSION} make -C . -f Makefile_zlib

Makefile_openssl:
	$(error Makefile_openssl is missing but required)

${OPENSSL_INSTALL}: Makefile_openssl
	OPENSSL_VERSION=${OPENSSL_VERSION} make -C . -f Makefile_openssl

Makefile_libevent:
	$(error Makefile_libevent is missing but required)

${LIBEVENT_INSTALL}: Makefile_libevent
	LIBEVENT_VERSION=${LIBEVENT_VERSION} make -C . -f Makefile_libevent


${TOR_TARBALL}:
	wget ${TOR_URL}

${TOR}: ${TOR_TARBALL}
	tar xvfz ${TOR_TARBALL}

${TOR_INSTALL}/bin/tor: ${TOR} ${ZLIB_INSTALL} ${OPENSSL_INSTALL} ${LIBEVENT_INSTALL}
	cd ${TOR}; CC=${LLVMCC} LDFLAGS=${LDFLAGS} CFLAGS=${CFLAGS} ./configure ${CFG_FLAGS};  make && make install

tor.bc: ${TOR_INSTALL}/bin/tor
	cd ${TOR_INSTALL}/bin; ${LLVMGET} tor; mv tor.bc ${THISDIR}



clean:
	rm -f ${BITCODE}
	make -C . -f Makefile_zlib clean
	make -C . -f Makefile_libevent clean
	make -C . -f Makefile_openssl clean
	make -C ${TOR} clean

very_clean: clean
	rm -rf ${TOR_INSTALL} ${TOR} 

spotless: very_clean
	rm -rf ${TOR_TARBALL}
