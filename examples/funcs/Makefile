
all:  main.o.bc call.o.bc


main.o.bc:
	wllvm main.c -c
	extract-bc main.o

call.o.bc:
	wllvm call.c -c
	extract-bc call.o



clean:
	rm -rf .*.bc *.o.bc *.o slash
