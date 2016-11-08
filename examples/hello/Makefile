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


all: hello_previrt hello_O3


hello.bc:
	wllvm hello.c -o  hello
	extract-bc hello

previrtualize: hello.bc
	${OCCAM_HOME}/bin/occam previrt --work-dir=previrt hello.manifest

slash: hello.bc
	slash --work-dir=slash hello.manifest

hello_previrt: previrtualize
	cp previrt/hello hello_previrt

hello_O3:
	${OPT} -O3 hello.bc -o hello.opt.bc
	${LLC} -filetype=obj -o hello.opt.o hello.opt.bc
	${CLANG} hello.opt.o -o hello_O3 


clean:
	rm -f *.o *~ *.bc .*.bc hello hello_O3 hello_previrt 
	rm -rf previrt slash





