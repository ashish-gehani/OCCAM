CFG_PATH=../test
OUTPUT_LOG=./out.log

LIT           = $(shell which lit)
FILECHECK     = $(shell which FileCheck)

test: clean
ifeq ($(LIT),)
	$(error you need to (pip) install lit)
endif
ifeq ($(FILECHECK),)
	$(error you need to install FileCheck (see README.md))
endif
	${LIT} --param=test_dir=../examples ${CFG_PATH} -v -o ${OUTPUT_LOG}

clean:
	rm -f out.log
	$(MAKE) -C ../examples/multiple clean
	$(MAKE) -C ../examples/simple clean
	$(MAKE) -C ../examples/tree clean
	$(MAKE) -C ../examples/funcs/1 clean
	$(MAKE) -C ../examples/funcs/2 clean
	$(MAKE) -C ../examples/funcs/3 clean
	$(MAKE) -C ../examples/funcs/4 clean
