
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

CFLAGS=-Xclang -disable-O0-optnone

all: main


${LIB}: library.c
	${CC} $(CFLAGS) ${LIBFLAGS}  library.c -o ${LIB}

main: main.c ${LIB}
	${CC} $(CFLAGS) -Wall  main.c -o main ${LIB}


clean:
	rm -f *~ ${LIB} .*.bc *.bc *.ll .*.o *.manifest main main_slash
	rm -rf slash
