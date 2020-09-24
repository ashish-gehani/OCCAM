#include <stdio.h>

#include "testlib1.h"

int add(int a, int b){
    return a + b;
}

int sub(int a, int b){
    return a - b;
}

int twice(int a){
    return add(a,a);
}

int multiply(int a, int b){
    return a * b;
}

int divide(int a, int b){
    if(b == 0){
        printf("Divide by zero!\n");
        return -1;
    }

    return a/b;
}

