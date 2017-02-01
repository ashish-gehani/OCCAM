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


all: ls_slash ls_O3


previrtualize: ls.bc
	slash --work-dir=slash ls.manifest

ls_slash: previrtualize
	cp slash/ls ls_slash

ls_O3:
	${OPT} -O3 ls.bc -o ls.opt.bc
	${LLC} -filetype=obj -o ls.opt.o ls.opt.bc
	${CLANG} ls.opt.o -o ls_O3 


clean:
	rm -f *.o *~ ls.opt.bc ls ls_O3 ls_slash
	rm -rf slash
