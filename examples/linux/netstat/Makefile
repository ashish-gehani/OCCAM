VERSION=1.60
SRC=net-tools-${VERSION}
TAR=v1.60.tar.gz
URL=https://github.com/ecki/net-tools/archive/v${VERSION}.tar.gz


all: ${SRC}/netstat

${TAR}:
	wget ${URL}

${SRC}: ${TAR}
	tar xvfz ${TAR}


${SRC}/netstat: ${SRC}
	cd ${SRC}; CC=gclang make config; CC=gclang make

spotless:
	rm -rf ${SRC} ${TAR}
