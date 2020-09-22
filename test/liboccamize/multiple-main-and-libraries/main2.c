#include "testlib1.h"
#include "testlib2.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>



int main(int argc, char** argv){
    int a = argc;
    int b = 40;

    int c = multiply(a,b);
    c += sequence_five(a);
    int len = strlen(argv[1]);

    printf("Main 2:\n");
    printf("Result on operator:\t%d\n",c);
    printf("len(argv[1]):\t%d\n",len);


    return 0;
}
