
#iam: producing the library varies from OS to OS
OS   =  $(shell uname)

LIBRARYNAME=library

ifeq (Darwin, $(findstring Darwin, ${OS}))
#  DARWIN
LIB = ${LIBRARYNAME}.dylib
LIBFLAGS = -Wall -dynamiclib
else
# LINUX
LIB = ${LIBRARYNAME}.so
LIBFLAGS = -shared -Wl,-soname,${LIB}
endif


all: main 


${LIB}: library.c 
	${CC} ${LIBFLAGS}  library.c -o ${LIB}

main: main.c library.dylib  
	${CC} -Wall  main.c -o main ${LIB}


clean:
	rm -f *~ ${LIB} *.bc *.ll *.o *.manifest main
	rm -rf previrt





