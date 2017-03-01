CFG_PATH=../test
OUTPUT_LOG=./out.log

LIT     = $(shell which lit)

test: 
ifeq ($(LIT),)
	$(error you need to (pip) install lit)
endif
	${LIT} --param=test_dir=../examples ${CFG_PATH} -v -o ${OUTPUT_LOG} 

clean:
	rm -f out.log
	$(MAKE) -C ../examples/multiple clean
	$(MAKE) -C ../examples/simple clean
	$(MAKE) -C ../examples/tree clean




