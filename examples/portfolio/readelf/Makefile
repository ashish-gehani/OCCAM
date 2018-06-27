
#COMPILER=wllvm
#EXTRACT_BC=extract-bc

COMPILER=gclang
EXTRACT_BC=get-bc
CURDIR=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

all: readelf.bc 

binutils:
	git clone git://sourceware.org/git/binutils-gdb.git binutils


binutils/binutils/readelf: binutils
	cd binutils; CC=${COMPILER} ./configure --disable-gdb --disable-libdecnumber --disable-readline --disable-sim
	make -C binutils

readelf.bc: binutils/binutils/readelf
	cd binutils/binutils; ${EXTRACT_BC} readelf; mv readelf.bc ../../

.PHONY: slash
slash:
	${CURDIR}/build.sh

clean:
	rm -rf ./binutils/binutils/readelf slash


distclean: clean
	rm -rf binutils readelf.bc readelf_slash readelf
