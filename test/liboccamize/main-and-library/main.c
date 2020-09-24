#include "testlib.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>



int main(int argc, char** argv){
    int a = argc;
    int b = 5;

    int c = add(a,b);
    int len = strlen(argv[1]);

    printf("Result on operator:\t%d\n",c);
    printf("len(argv[1]):\t%d\n",len);


    return 0;
}
