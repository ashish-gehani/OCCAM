
#iam: producing the library varies from OS to OS
OS   =  $(shell uname)

all: harness.o


%.o: %.c
	${CC} ${CFLAGS} $< -c -o $@


clean:
	rm -f *~ *.o .*.bc *.bc .*.o *.manifest
	rm -rf slash
