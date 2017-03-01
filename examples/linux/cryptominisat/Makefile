SRC="https://github.com/msoos/cryptominisat/archive/cryptominisat-5.0.0.tar.gz"


all: cryptominisat4.bc


cryptominisat-5.0.0.tar.gz:
	curl -L ${SRC} > ./cryptominisat-5.0.0.tar.gz


cryptominisat: cryptominisat-5.0.0.tar.gz
	gunzip -k cryptominisat-5.0.0.tar.gz
	tar xvf cryptominisat-5.0.0.tar
	mv cryptominisat-cryptominisat-5.0.0 cryptominisat


cryptominisat4.bc: cryptominisat
	mkdir -p cryptominisat/build
	cd cryptominisat/build; CC=wllvm CXX=wllvm++ cmake ..; make
	extract-bc cryptominisat/build/cryptominisat5
	mv cryptominisat/build/cryptominisat5.bc .


clean:
	rm -rf *~ cryptominisat cryptominisat-5.0.0.tar 

spotless:   clean
	rm -f *.gz *.bc

