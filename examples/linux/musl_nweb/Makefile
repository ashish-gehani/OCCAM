


all: 
	@echo "Just type ./build.sh; this is here just for 'make clean'"



libc.a.bc:
	make -C ../musllvm
	cp ../musllvm/libc.a.bc ../musllvm/libc.so.bc ../musllvm/libc.a ../musllvm/crt1.o .


clean:
	rm -rf *.a *.bc .*.bc .*.o *.s nweb nweb-base nweb.manifest nweb*.o previrt occam.log index.html* root/nweb.log

