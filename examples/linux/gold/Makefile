BINUTILS="git://sourceware.org/git/binutils-gdb.git"

all:  build


binutils:
	git clone ${BINUTILS} binutils


build:  binutils
	mkdir build; cd build; ../binutils/configure --enable-gold --enable-plugins --disable-werror; make all-gold



clean: 
	rm -rf build

veryclean: clean
	rm -rf binutils


.PHONY: clean veryclean

