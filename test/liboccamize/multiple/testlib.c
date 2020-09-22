#include <stdio.h>


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
    return a*b;
}

int divide(int a, int b){
    int res = a/b;
    return res;
}
