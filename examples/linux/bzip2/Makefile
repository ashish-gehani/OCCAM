all: bzip2.bc


./bzip2: 
	git clone git://sourceware.org/git/bzip2.git
# the patch is to remove the hard coded "CC=gcc". Bad Julian. No biscuit.
	patch bzip2/Makefile < patch.txt

./bzip2/bzip2: bzip2
	CC=gclang make -C bzip2

./bzip2.bc: bzip2/bzip2 libbz2.bca libbz2.a.bc
	cd bzip2; get-bc bzip2; mv bzip2.bc ../

# to build an bitcode archive we do not use any additional flags; the '-m' flag writes the manifest (i.e. the ingredients)
libbz2.bca:
	cd bzip2; get-bc -m libbz2.a; mv libbz2.bca libbz2.bca.llvm.manifest ../

# to build a module we just use the '-b' flag; the '-m' flag writes the manifest (i.e. the ingredients)
libbz2.a.bc:
	cd bzip2; get-bc -m -b libbz2.a; mv libbz2.a.bc libbz2.a.bc.llvm.manifest ../

# groked this list from the manifests
modules: bzip2/bzip2
	cp ./bzip2/.blocksort.o.bc  blocksort.o.bc
	cp ./bzip2/.huffman.o.bc    huffman.o.bc
	cp ./bzip2/.crctable.o.bc   crctable.o.bc
	cp ./bzip2/.randtable.o.bc  randtable.o.bc
	cp ./bzip2/.compress.o.bc   compress.o.bc
	cp ./bzip2/.decompress.o.bc decompress.o.bc
	cp ./bzip2/.bzlib.o.bc      bzlib.o.bc


# the override flag is necessary and is there to prevent any complaints about multiple definitions.
bzip2_from_bitcode: bzip2.bc modules
	llvm-link -override bzip2.bc blocksort.o.bc huffman.o.bc crctable.o.bc randtable.o.bc compress.o.bc decompress.o.bc bzlib.o.bc -o almalgamation.bc
	clang almalgamation.bc -o bzip2_from_bitcode

test: bzip2_from_bitcode
	./bzip2_from_bitcode -1  < ./bzip2/sample1.ref > sample1.rb2
	./bzip2_from_bitcode -2  < ./bzip2/sample2.ref > sample2.rb2
	./bzip2_from_bitcode -3  < ./bzip2/sample3.ref > sample3.rb2
	./bzip2_from_bitcode -d  < ./bzip2/sample1.bz2 > sample1.tst
	./bzip2_from_bitcode -d  < ./bzip2/sample2.bz2 > sample2.tst
	./bzip2_from_bitcode -ds < ./bzip2/sample3.bz2 > sample3.tst
	cmp ./bzip2/sample1.bz2 sample1.rb2 
	cmp ./bzip2/sample2.bz2 sample2.rb2
	cmp ./bzip2/sample3.bz2 sample3.rb2
	cmp sample1.tst ./bzip2/sample1.ref
	cmp sample2.tst ./bzip2/sample2.ref
	cmp sample3.tst ./bzip2/sample3.ref

clean:
	rm -f *.bc *.bca *.manifest bzip2_from_bitcode *.rb2 *.tst bzip2_slashed
	rm -rf slash_specialized
	make -C bzip2 clean

spotless: clean
	rm -rf bzip2 bzip2_tests



.PHONY: clean spotless modules
