


all: 
	@echo "Just type ./build.sh; this is here just for 'make clean'"



libc.a.bc:
	make -C ../musllvm
	cp ../musllvm/libc.a.bc ../musllvm/libc.so.bc ../musllvm/libc.a ../musllvm/crt1.o .

nweb.bc:
	clang -c nweb.c -emit-llvm

nweb:
	clang -static -nostdlib nweb.bc libc.a.bc crt1.o libc.a /usr/lib/gcc/x86_64-linux-gnu/4.8/libgcc.a -o nweb


clean:
	rm -rf *.a *.bc .*.bc .*.o *.s nweb nweb-base *.manifest nweb*.o previrt occam.log index.html* root/nweb.log

