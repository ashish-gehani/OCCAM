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


all: main_slash 


main.bc:
	wllvm main.c lib.c -o  main
	extract-bc main

slash: main.bc
	slash --work-dir=slash main.manifest

main_slash: slash
	cp slash/main main_slash

# main_O3:
# 	${OPT} -O3 main.bc -o main.opt.bc
# 	${LLC} -filetype=obj -o main.opt.o main.opt.bc
# 	${CLANG} main.opt.o -o main_O3


clean:
	rm -f *.o .*.o *~ *.bc .*.bc main main_O3
	rm -rf slash main_slash
