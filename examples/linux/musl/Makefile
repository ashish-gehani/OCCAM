
SRC="http://www.musl-libc.org/releases/musl-1.1.15.tar.gz"


all: libc.bca

musl-1.1.15.tar.gz:
	curl -L ${SRC} > musl-1.1.15.tar.gz

musl-1.1.15.tar: musl-1.1.15.tar.gz
	gunzip -k musl-1.1.15.tar.gz

musl-1.1.15: musl-1.1.15.tar
	tar xvf musl-1.1.15.tar

libc.bca: musl-1.1.15
	cd musl-1.1.15; WLLVM_CONFIGURE_ONLY=1 CC=wllvm ./configure --disable-shared; make
	cd musl-1.1.15/lib; extract-bc libc.a; mv libc.bca ../../




