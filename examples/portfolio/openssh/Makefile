#iam wrote this monstrosity

THISDIR =  $(shell pwd)
OS      =  $(shell uname)
ARCH    =  $(shell uname -p)

ZLIB_VERSION = 1.2.11
export ZLIB_VERSION

OPENSSL_VERSION=1.0.2o
export OPENSSL_VERSION


OPENSSL_INSTALL=${THISDIR}/install/openssl

ZLIB_INSTALL=${THISDIR}/install/zlib


LLVMCC ?= gclang
LLVMGET ?= get-bc

export LLVMCC
export LLVMGET

OPENSSH=openssh-7.7p1
OPENSSH_TARBALL=${OPENSSH}.tar.gz
OPENSSH_URL=https://mirrors.sonic.net/pub/OpenBSD/OpenSSH/portable/${OPENSSH_TARBALL}
OPENSSH_INSTALL=${THISDIR}/install/openssh

ifeq (Darwin, $(findstring Darwin, ${OS}))

LIBEXT=dylib

else

LIBEXT=so

endif


CFLAGS="-I${OPENSSL_INSTALL}/include -Wl,-rpath,${OPENSSL_INSTALL}/lib"
LDFLAGS="-L${OPENSSL_INSTALL}/lib"


BITCODE=ssh.bc sshd.bc

all: ${BITCODE}


Makefile_zlib:
	$(error Makefile_zlib is missing but required)

${ZLIB_INSTALL}: Makefile_zlib
	make -C . -f Makefile_zlib

Makefile_openssl:
	$(error Makefile_openssl is missing but required)

${OPENSSL_INSTALL}: Makefile_openssl
	make -C . -f Makefile_openssl


${OPENSSH_TARBALL}:
	wget ${OPENSSH_URL}

${OPENSSH}: ${OPENSSH_TARBALL}
	tar xvfz ${OPENSSH_TARBALL}

${OPENSSH}/Makefile:  ${ZLIB_INSTALL} ${OPENSSL_INSTALL} ${OPENSSH} 
	cd ${OPENSSH}; autoconf
	cd ${OPENSSH}; CC=${LLVMCC} LDFLAGS=${LDFLAGS} CFLAGS=${CFLAGS} ./configure  --prefix=${OPENSSH_INSTALL}  --with-openssl-dir=${OPENSSL_INSTALL}

${OPENSSH}/ssh: ${OPENSSH}/Makefile
	cd ${OPENSSH}; CC=${LLVMCC} make && make install

ssh.bc: ${OPENSSH}/ssh
	cd ${OPENSSH_INSTALL}/bin; ${LLVMGET} ssh; mv ssh.bc ${THISDIR}

sshd.bc: ${OPENSSH}/ssh
	cd ${OPENSSH_INSTALL}/sbin; ${LLVMGET} sshd; mv sshd.bc ${THISDIR}


clean:
	rm -f ${BITCODE} libssl.a.bc libcrypto.a.bc

very_clean:
	rm -rf install ${OPENSSH} ${OPENSSH_BITCODE}

spotless: very_clean
	rm -rf ${OPENSSH_TARBALL}
	OPENSSL_VERSION=${OPENSSL_VERSION} make -C . -f Makefile_openssl spotless

