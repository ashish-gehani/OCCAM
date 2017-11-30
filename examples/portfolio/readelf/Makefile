
#COMPILER=wllvm
COMPILER=gclang
EXTRACT_BC=get-bc
all: build


binutils:
	git clone git://sourceware.org/git/binutils-gdb.git binutils


build: binutils
	cd binutils; CC=${COMPILER} ./configure --disable-gdb --disable-libdecnumber --disable-readline --disable-sim
	make -C binutils

readelf.bc: build
	cd binutils/binutils; ${EXTRACT_BC} readelf; mv readelf.bc ../../

clean:
	rm -f ./binutils/binutils/readelf

distclean: clean
	rm -rf binutils
