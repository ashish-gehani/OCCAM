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


int decide(int a, int b, char mode){

    int (*operator)(int,int) = NULL;
    
    switch(mode){
        case 'a':
            operator = &add;
            break;
        case 's':
            operator = &sub;
            break;
        case 'm':
            operator = &multiply;
            break;
    }

    return operator? operator(a,b):-1;
}
