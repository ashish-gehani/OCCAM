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
# Test OCCAM features
	${LIT} --param=test_dir=simple-c simple -v -o ${OUTPUT_LOG}
# Test inter-procedural dead store elimination
#	${LIT} --param=test_dir=ipdse ipdse -v -o ${OUTPUT_LOG}

clean:
	rm -f out.log
	$(MAKE) -C simple-c/multiple clean
	$(MAKE) -C simple-c/simple clean
	$(MAKE) -C simple-c/tree clean
	$(MAKE) -C simple-c/funcs/1 clean
	$(MAKE) -C simple-c/funcs/2 clean
	$(MAKE) -C simple-c/funcs/3 clean
	$(MAKE) -C simple-c/funcs/4 clean
	$(MAKE) -C simple-c/funcs/5 clean
	$(MAKE) -C simple-c/funcs/6 clean
	$(MAKE) -C simple-c/funcs/7 clean
	$(MAKE) -C simple-c/funcs/8 clean
	$(MAKE) -C simple-c/funcs/9 clean
	$(MAKE) -C simple-c/funcs/10 clean
	$(MAKE) -C simple-c/funcs/11 clean
	$(MAKE) -C simple-c/funcs/12 clean
	$(MAKE) -C simple-c/funcs/13 clean
	$(MAKE) -C simple-c/funcs/14 clean
	$(MAKE) -C simple-c/fib clean
	$(MAKE) -C simple-c/fiblib clean
	$(MAKE) -C simple-c/bounded-intra clean
	$(MAKE) -C simple-c/bounded-inter clean
	$(MAKE) -C simple-c/onlyonce-intra clean
	$(MAKE) -C simple-c/onlyonce-inter clean
	$(MAKE) -C simple-c/pe clean
	$(MAKE) -C ipdse clean
