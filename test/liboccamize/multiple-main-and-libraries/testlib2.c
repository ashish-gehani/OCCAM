#include <stdio.h>

#include "testlib2.h"


int sequence_one(int a){
    return (9*a) + 263;
}

int sequence_two(int b){
    return ((2*b*b)%5)+11;
}

int sequence_three(int b){
    return ((2*b*b)%5)+11*3;
}

int sequence_four(int b){
    return ((2*b*b)%5)+11*4;
}

int sequence_five(int b){
    return ((2*b*b)%5)+11*5;
}

