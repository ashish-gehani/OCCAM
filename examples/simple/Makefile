
all: main 


library.dylib: library.c 
	${CC} -Wall -dynamiclib library.c -o library.dylib

main: main.c library.dylib  
	${CC} -Wall  main.c -o main library.dylib


clean:
	rm -f *~ library.dylib *.bc *.ll *.o *.manifest main
	rm -rf previrt





