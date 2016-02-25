

BITCODE = libpoly.so.bc yices_main.bc yices_smt2.bc  yices_smt2_release_mcsat.bc



all: ${BITCODE} run

run:
	./build.sh

%.bc: %.bc.gz
	gunzip -k $<



clean:
	rm -rf previrt ${BITCODE} *.manifest

previrt/%.ll: previrt/%.bc
	llvm-dis $<

FILES_OF_INTEREST = previrt/libpoly.so.ll \
		    previrt/libpoly.so.i.ll \
                    previrt/yices_smt2_release_mcsat.ll \
		    previrt/yices_smt2_release_mcsat.i.ll \
		    previrt/libpoly.so.i.x.ll \
                    previrt/libpoly.so.i.x.p.ll \
	            previrt/libpoly.so-final.ll \
	            previrt/yices_smt2_release_mcsat-final.ll

readable: ${FILES_OF_INTEREST}

