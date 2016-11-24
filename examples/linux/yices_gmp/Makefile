
BITCODE = yices_smt2.bc libgmp.so.bc


all: ${BITCODE} run

run:
	./build.sh

%.bc: %.bc.gz
	gunzip -k $<


clean:
	rm -rf slash ${BITCODE} *.manifest

previrt/%.ll: slash/%.bc
	llvm-dis $<
