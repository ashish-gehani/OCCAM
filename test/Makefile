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
# Test simple OCCAM features
	${LIT} --param=test_dir=simple-c simple-bitcode -v -o ${OUTPUT_LOG}
# Test configuration prime
	${LIT} --param=test_dir=config-prime-c config-prime-bitcode -v -o ${OUTPUT_LOG}
# Test inter-procedural dead store elimination
	${LIT} --param=test_dir=ipdse ipdse -v -o ${OUTPUT_LOG}

clean:
	rm -f out.log
	$(MAKE) -C simple-c clean
	$(MAKE) -C config-prime-c clean
	$(MAKE) -C ipdse clean
