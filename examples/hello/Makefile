ifeq ($(LLVM_OPT_NAME),)
  OPT = opt
else
  OPT = $(LLVM_OPT_NAME)
endif

ifeq ($(LLVM_LLC_NAME),)
  LLC = llc
else
  LLC = $(LLVM_LLC_NAME)
endif

ifeq ($(LLVM_CC_NAME),)
  CLANG = clang
else
  CLANG = $(LLVM_CC_NAME)
endif


all: hello_slash hello_O3


hello.bc:
	wllvm hello.c -o  hello
	extract-bc hello

razor: hello.bc
	slash --work-dir=slash hello.manifest

hello_razor: razor
	cp slash/hello hello_slash

hello_O3:
	${OPT} -O3 hello.bc -o hello.opt.bc
	${LLC} -filetype=obj -o hello.opt.o hello.opt.bc
	${CLANG} hello.opt.o -o hello_O3


clean:
	rm -f *.o .*.o *~ *.bc .*.bc hello hello_O3
	rm -rf slash hello_slash
