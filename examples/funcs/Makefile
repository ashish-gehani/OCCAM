
all:  main.o.bc call.o.bc slash


main.o.bc:
	wllvm main.c -c
	extract-bc main.o

call.o.bc:
	wllvm call.c -c
	extract-bc call.o

slash:
	slash --work-dir=slash funcs.manifest


clean:
	rm -rf .*.bc *.o.bc *.o slash
