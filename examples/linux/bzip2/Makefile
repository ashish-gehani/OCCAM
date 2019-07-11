all: bzip2.bc


bzip2: 
	git clone git://sourceware.org/git/bzip2.git
# the patch is to remove the hard coded "CC=gcc". Bad Julian. No biscuit.
	patch bzip2/Makefile < patch.txt

bzip2/bzip2: bzip2
	cd bzip2;  CC=gclang make

bzip2.bc: bzip2/bzip2 libbz2.bca libbz2.a.bc
	cd bzip2; get-bc bzip2; mv bzip2.bc ../

# to build an bitcode archive we do not use any additional flags; the '-m' flag writes the manifest (i.e. the ingredients)
libbz2.bca:
	cd bzip2; get-bc -m libbz2.a; mv libbz2.bca libbz2.bca.llvm.manifest ../

# to build a module we just use the '-b' flag; the '-m' flag writes the manifest (i.e. the ingredients)
libbz2.a.bc:
	cd bzip2; get-bc -m -b libbz2.a; mv libbz2.a.bc libbz2.a.bc.llvm.manifest ../


clean:
	rm -f *.bc *.bca *.manifest


spotless:
	rm -rf bzip2 bzip2_tests



