#include <stdio.h>


int add(int a, int b){
    return a + b;
}

int add(int a, int b, int c){
    return a+b+c;
}


int sub(int a, int b){
    return a - b;
}

int twice(int a){
    return add(a,a);
}
