
#iam: producing the library varies from OS to OS
OS   =  $(shell uname)

LIBRARYNAME=library

ifeq (Darwin, $(findstring Darwin, ${OS}))
#  DARWIN
## We use .so to make easier tests
LIB = ${LIBRARYNAME}.so
LIBFLAGS = -Wall -fPIC -dynamiclib
else
# LINUX
LIB = ${LIBRARYNAME}.so
LIBFLAGS = -shared -fPIC  -Wl,-soname,${LIB}
endif


all: main


${LIB}: library.c
	${CC} -O2 ${LIBFLAGS}  library.c -o ${LIB}

main: main.c ${LIB}
	${CC} -O2 -Wall  main.c -o main ${LIB}


clean:
	rm -f *~ ${LIB} .*.bc *.bc *.ll .*.o *.manifest manifest main main_slash
	rm -rf slash
	rm -f *.so
