TORDIR= $(shell pwd)

TOR=tor-0.3.3.6
TOR_URL=https://www.torproject.org/dist/${TOR}.tar.gz
TOR_INSTALL=${TORDIR}/install/

all: tor.bc

${TOR}.tar.gz:
	wget ${TOR_URL}

${TOR}: ${TOR}.tar.gz
	tar xvfz ${TOR}.tar.gz

tor.bc: ${TOR}
	cd ${TOR}; CC=gclang ./configure --prefix=${TOR_INSTALL}; make && make install




very_clean:
	rm -rf ${TOR} ${TOR_INSTALL}

spotless: very_clean
	rm -rf ${TOR}.tar.gz
