#iam wrote this monstrosity

THISDIR =  $(shell pwd)
OS      =  $(shell uname)
ARCH    =  $(shell uname -p)


OPENSSL_INSTALL=${THISDIR}/install/openssl


#LLVMCC=wllvm
#LLVMGET=extract-bc

LLVMCC=gclang
LLVMGET=get-bc

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

OPENSSH_BITCODE=ssh.bc sshd.bc

all: ${OPENSSH_BITCODE}

${OPENSSH_TARBALL}:
	wget ${OPENSSH_URL}

${OPENSSH}: ${OPENSSH_TARBALL}
	tar xvfz ${OPENSSH_TARBALL}

${OPENSSH}/Makefile: ${OPENSSH} libssl.a.bc
	cd ${OPENSSH}; autoconf
	cd ${OPENSSH}; CC=${LLVMCC} LDFLAGS=${LDFLAGS} CFLAGS=${CFLAGS} ./configure  --prefix=${OPENSSH_INSTALL}  --with-openssl-dir=${OPENSSL_INSTALL}

${OPENSSH}/ssh: ${OPENSSH}/Makefile
	cd ${OPENSSH}; CC=${LLVMCC} make && make install

ssh.bc: ${OPENSSH}/ssh
	cd ${OPENSSH_INSTALL}/bin; ${LLVMGET} ssh; mv ssh.bc ${THISDIR}

sshd.bc: ${OPENSSH}/ssh
	cd ${OPENSSH_INSTALL}/sbin; ${LLVMGET} sshd; mv sshd.bc ${THISDIR}


libssl.a.bc:
	make -C . -f Makefile_openssl


very_clean:
	rm -rf ${OPENSSH} ${OPENSSH_BITCODE}
	make -C . -f Makefile_openssl very_clean


spotless: very_clean
	rm -rf ${OPENSSH_TARBALL}
	make -C . -f Makefile_openssl spotless
