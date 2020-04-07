test: 
	gclang -c ./test.c
	gclang -c ./main.c

#main.bc: main.c
#	clang -c -emit-llvm ./main.c

clean:
	rm -f *.bc *.o *.a .*.bc .*.o
	rm -f test.manifest
	rm -Rf OCCAM
