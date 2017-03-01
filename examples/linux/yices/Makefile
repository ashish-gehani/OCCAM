
BITCODE = libpoly.so.bc yices_main.bc yices_smt2_release.bc yices_smt2.bc  yices_smt2_release_mcsat.bc


all: ${BITCODE} run

run:
	./build.sh

%.bc: %.bc.gz
	gunzip -k $<



clean:
	rm -rf slash ${BITCODE} *.manifest

previrt/%.ll: previrt/%.bc
	llvm-dis $<
