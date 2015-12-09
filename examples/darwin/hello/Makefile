ifeq ($(LVM_OPT_NAME),)
  OPT = opt
else
  OPT = $(LVM_OPT_NAME)
endif

ifeq ($(LVM_LLC_NAME),)
  LLC = llc
else
  LLC = $(LVM_LLC_NAME)
endif

ifeq ($(LVM_CLANG_NAME),)
  CLANG = clang
else
  CLANG = $(LVM_CLANG_NAME)
endif


all: hello_previrt hello_O3


hello.bc:
	wllvm hello.c -o  hello
	extract-bc hello

previrtualize: hello.bc
	${OCCAM_HOME}/bin/occam previrt --work-dir=previrt hello.manifest

hello_previrt: previrtualize
	cp previrt/hello hello_previrt

hello_O3:
	${OPT} -O3 hello.bc -o hello.opt.bc
	${LLC} -filetype=obj -o hello.opt.o hello.opt.bc
	${CLANG} hello.opt.o -o hello_O3 


clean:
	rm -f *.o *~ *.bc .*.bc hello hello_O3 hello_previrt 
	rm -rf previrt





