





all: libc.a.bc main.o.bc


musllvm:
	git clone https://github.com/SRI-CSL/musllvm.git

musllvm/lib/libc.a: musllvm
	cd musllvm && CC=gclang WLLVM_CONFIGURE_ONLY=1  ./configure --target=LLVM --build=LLVM && make

libc.a.bc: musllvm/lib/libc.a
	cd musllvm/lib && get-bc -b libc.a && cp libc.a.bc ../../ && cp libc.a ../../ && cp crt1.o  ../../

main.o.bc:
	gclang main.c -c  && get-bc main.o

clean:
	rm -rf *.bc .*.bc *.o *.a slash main_static main_slash

very_clean: clean
	make -C ./musllvm clean

spotless:
	rm -rf musllvm
