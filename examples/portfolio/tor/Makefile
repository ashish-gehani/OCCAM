TORDIR= $(shell pwd)

TOR=tor-0.3.3.6
TOR_URL=https://www.torproject.org/dist/${TOR}.tar.gz
TOR_INSTALL=${TORDIR}/install/


LLVMCC=wllvm
LLVMGET=extract-bc

#LLVMCC=gclang
#LLVMGET=get-bc


all: tor.bc

${TOR}.tar.gz:
	wget ${TOR_URL}

${TOR}: ${TOR}.tar.gz
	tar xvfz ${TOR}.tar.gz

install/bin/tor: ${TOR}
	cd ${TOR}; CC=${LLVMCC} ./configure --prefix=${TOR_INSTALL}; make && make install

tor.bc: install/bin/tor
	cd install/bin; ${LLVMGET} tor; mv tor.bc ../../


very_clean:
	rm -rf ${TOR} ${TOR_INSTALL}

spotless: very_clean
	rm -rf ${TOR}.tar.gz
