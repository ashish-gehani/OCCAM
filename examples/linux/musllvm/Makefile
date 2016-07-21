SRC="https://github.com/SRI-CSL/musllvm"


all: libc.a.bc


musllvm:
	git clone ${SRC}

libc.a: musllvm
	cd musllvm; WLLVM_CONFIGURE_ONLY=1  CC=wllvm ./configure --target=LLVM
	cd musllvm; make; cp lib/libc.a ../; cp lib/crt1.o ../

libc.a.bc: libc.a
	cd musllvm/lib; extract-bc -b libc.a; cp libc.a.bc ../../



