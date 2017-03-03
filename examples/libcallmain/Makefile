
#iam: producing the library varies from OS to OS
OS   =  $(shell uname)

all: main


%.o: %.c
	${CC} ${CFLAGS} $< -c -o $@


main: main.o library.o
	${CC} -Wall  main.o library.o -o main


clean:
	rm -f *~ *.o .*.bc *.bc *.ll .*.o *.manifest main main_slash
	rm -rf slash
