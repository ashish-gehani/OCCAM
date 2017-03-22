
all:  main.o.bc call.o.bc

main.o.bc: 
	wllvm main.c call.c -o main
	wllvm main.c -c
	extract-bc main.o

call.o.bc:
	wllvm call.c -c
	extract-bc call.o

clean:
	rm -rf .*.bc *.o.bc *.o *.manifest slash main main_slash
