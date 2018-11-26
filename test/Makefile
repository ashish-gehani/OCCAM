OUTPUT_LOG=./out.log

LIT           = $(shell which lit)
FILECHECK     = $(shell which FileCheck)

# Usage: lit --param=test_dir=SRC_DIR CFG_DIR
# where SRC_DIR is the directory where test sources are located
#       CFG_DIR is the directory where cfg file is located

test: clean
ifeq ($(LIT),)
	$(error you need to (pip) install lit)
endif
ifeq ($(FILECHECK),)
	$(error you need to install FileCheck (see README.md))
endif
# Test simple features
	${LIT} --param=test_dir=../examples ../test/simple -v -o ${OUTPUT_LOG}
# Test inter-procedural dead store elimination
	${LIT} --param=test_dir=../test/ipdse ../test/ipdse -v -o ${OUTPUT_LOG}

clean:
	rm -f out.log
	$(MAKE) -C ../examples/multiple clean
	$(MAKE) -C ../examples/simple clean
	$(MAKE) -C ../examples/tree clean
	$(MAKE) -C ../examples/funcs/1 clean
	$(MAKE) -C ../examples/funcs/2 clean
	$(MAKE) -C ../examples/funcs/3 clean
	$(MAKE) -C ../examples/funcs/4 clean
	$(MAKE) -C ../test/ipdse clean
