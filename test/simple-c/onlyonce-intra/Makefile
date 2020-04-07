
#iam: producing the library varies from OS to OS
OS   =  $(shell uname)

LIBRARYNAME=library

ifeq (Darwin, $(findstring Darwin, ${OS}))
#  DARWIN
LIB = ${LIBRARYNAME}.dylib
LIBFLAGS = -Wall -fPIC -dynamiclib
else
# LINUX
LIB = ${LIBRARYNAME}.so
LIBFLAGS = -shared -fPIC  -Wl,-soname,${LIB}
endif


all: main

main: main.c 
	${CC} -Wall -Xclang -disable-O0-optnone main.c -o main 


clean:
	rm -f .*.bc *.bc *.ll .*.o *.manifest main main_slash
	rm -rf slash
