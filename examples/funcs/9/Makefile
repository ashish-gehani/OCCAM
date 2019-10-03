CCFLAGS = -Xclang -disable-O0-optnone
all: main


main: main.cpp ${LIB}
	${CXX} ${CCFLAGS}  main.cpp -o main

clean:
	rm -f *~ ${LIB} .*.bc *.bc *.ll .*.o *.manifest main main_slash
	rm -rf slash
