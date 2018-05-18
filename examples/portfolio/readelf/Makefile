
#COMPILER=wllvm
#EXTRACT_BC=extract-bc

COMPILER=gclang
EXTRACT_BC=get-bc

MANIFEST=readelf.manifest

all: slash


binutils:
	git clone git://sourceware.org/git/binutils-gdb.git binutils


binutils/binutils/readelf: binutils
	cd binutils; CC=${COMPILER} ./configure --disable-gdb --disable-libdecnumber --disable-readline --disable-sim
	make -C binutils

readelf.bc: binutils/binutils/readelf
	cd binutils/binutils; ${EXTRACT_BC} readelf; mv readelf.bc ../../

slash: readelf.bc
	slash --stats --devirt --no-strip --work-dir=slash $(MANIFEST)
	cp slash/readelf readelf_slash
	cp  binutils/binutils/readelf readelf_orig


clean:
	rm -rf ./binutils/binutils/readelf slash


distclean: clean
	rm -rf binutils readelf.bc readelf_slash readelf
