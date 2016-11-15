
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

OBJS = main.o module.o

CFLAGS = -Wall

all: main


${LIB}: library.c
	${CC} ${CFLAGS} ${LIBFLAGS}  library.c -o ${LIB}

%.o: %.c
	${CC} ${CFLAGS} $< -c


main:  ${OBJS} ${LIB}
	${CC}  ${CFLAGS}  ${OBJS} -o main ${LIB}


clean:
	rm -f *~ ${LIB} .*.bc *.bc *.ll *.o *.manifest main
	rm -rf slash main_slash
