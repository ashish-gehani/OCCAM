

BITCODE = libpoly.so.bc yices_main.bc yices_smt2.bc  yices_smt2_mcsat.bc



all: ${BITCODE} run

run:
	./build.sh

%.bc: %.bc.gz
	gunzip -k $<



clean:
	rm -rf previrt ${BITCODE} *.manifest


