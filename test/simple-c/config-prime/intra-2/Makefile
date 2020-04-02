all: main

main: main.c 
	${CC} -Wall -Xclang -disable-O0-optnone main.c -o main 

clean:
	rm -f .*.bc *.bc *.ll .*.o *.manifest main main_slash
	rm -rf slash
