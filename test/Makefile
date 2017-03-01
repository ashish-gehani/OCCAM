LLVM_LIT=${LLVM_HOME}/../utils/lit/lit.py
CFG_PATH=${OCCAM_HOME}/test
OUTPUT_LOG=./out.log

check_llvm_lit:
	@test -s ${LLVM_LIT} || (echo "${LLVM_LIT} not found" ; exit 1)

test: check_llvm_lit 
	@python ${LLVM_LIT} --param=test_dir=${OCCAM_HOME}/examples ${CFG_PATH} -v -o ${OUTPUT_LOG} 

clean:
	rm -f out.log
	$(MAKE) -C ${OCCAM_HOME}/examples/multiple clean
	$(MAKE) -C ${OCCAM_HOME}/examples/simple clean
	$(MAKE) -C ${OCCAM_HOME}/examples/tree clean




