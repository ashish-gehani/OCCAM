
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

CCFLAGS = -Xclang -disable-O0-optnone
all: main


${LIB}: library.c
	${CC} ${CCFLAGS} ${LIBFLAGS}  library.c -o ${LIB}

main: main.c ${LIB}
	${CC} ${CCFLAGS} -Wall mystring.c main.c -o main ${LIB}


clean:
	rm -f *~ ${LIB} .*.bc *.bc *.ll .*.o *.manifest main main_slash
	rm -rf slash
