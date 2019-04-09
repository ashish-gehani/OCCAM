
all:  main.o.bc call.o.bc

main.o.bc: 
	gclang main.c call.c -o main
	gclang main.c -c
	get-bc main.o

call.o.bc:
	gclang call.c -c
	get-bc call.o

clean:
	rm -rf .*.bc *.o.bc *.o *.manifest slash main main_slash
