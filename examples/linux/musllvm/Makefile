SRC="https://github.com/SRI-CSL/musllvm"


all: libc.a.bc libc.so.bc


musllvm:
	git clone ${SRC}

libc.a: musllvm
	cd musllvm; WLLVM_CONFIGURE_ONLY=1  CC=gclang ./configure  --target=LLVM --build=LLVM
	cd musllvm; make; cp lib/libc.a ../; cp lib/crt1.o ../

libc.a.bc: libc.a
	cd musllvm/lib; get-bc -b libc.a; cp libc.a.bc ../../


libc.so.bc: libc.a
	cd musllvm/lib; get-bc libc.so; cp libc.so.bc ../../


clean:
	rm -rf musllvm

spotless: clean
	rm -f *.bc *.a

.PHONY: clean spotless


