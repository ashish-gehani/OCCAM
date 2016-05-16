
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

OBJS = main.o subdir/module.o

CFLAGS = -Wall 

all: main 


${LIB}: library.c 
	${CC} ${CFLAGS} ${LIBFLAGS}  library.c -o ${LIB}

%.o: %.c
	${CC} ${CFLAGS} $< -c 

subdir/module.o: subdir/module.c
	${CC} ${CFLAGS} subdir/module.c -c -o subdir/module.o


main:  ${OBJS} ${LIB}
	${CC}  ${CFLAGS}  ${OBJS} -o main ${LIB}


clean:
	rm -f *~ ${LIB} .*.bc *.bc *.ll *.o .*.o *.manifest main
	cd subdir; rm -f *~  .*.bc *.bc *.ll *.o *.o 
	rm -rf previrt





