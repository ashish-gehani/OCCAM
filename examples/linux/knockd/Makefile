# sudo apt-get install libpcap-dev

SRC=knock-0.7
TAR=${SRC}.tar.gz
URL=http://www.zeroflux.org/proj/knock/files/${TAR}

all: knock.bc knockd.bc

${TAR}:
	wget ${URL}

${SRC}: ${TAR}
	tar xvfz ${TAR}

${SRC}/knockd: ${SRC}
	cd ${SRC}; CC=gclang ./configure; make; 

knockd.bc: ${SRC}/knockd modules
	get-bc -m -o knockd.bc ${SRC}/knockd

knock.bc: ${SRC}/knock modules
	get-bc -m -o knock.bc ${SRC}/knock

modules: ${SRC}/knockd
	cp ./knock-0.7/src/.knockd.o.bc knockd.o.bc
	cp ./knock-0.7/src/.list.o.bc list.o.bc


test: knockd.bc
	gclang knockd.o.bc list.o.bc -o knockd_from_bitcode -lpcap


clean:
	rm -rf .*.o *.bc *.llvm.manifest knockd_from_bitcode	knockd_slashed slash_specialized

spotless: clean
	rm -rf ${TAR} ${SRC}

