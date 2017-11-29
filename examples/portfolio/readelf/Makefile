all: build


binutils:
	git clone git://sourceware.org/git/binutils-gdb.git binutils


build: binutils
	cd binutils; CC=wllvm ./configure --disable-gdb --disable-libdecnumber --disable-readline --disable-sim
	make -C binutils


clean:


distclean: clean
	rm -rf binutils


