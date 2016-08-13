



all: cpow.ll

cpow.bc:
	clang -rtlib=compile-rt cpow.c -c -emit-llvm

cpow.ll: cpow.bc
	llvm-dis cpow.bc

main:
	clang main.c -o main -lm


clean:
	rm -f *.o *.bc *.ll *~ main


.PHONY: clean
