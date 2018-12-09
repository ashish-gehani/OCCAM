#include <stdio.h>
#include <stdlib.h>

#include "library.h"


int main(int argc, char* argv[]){
  if (argc == 2) {
    // Currently, user-input specialization does not understand
    // library calls such as atoi.
    //int n = atoi(argv[1]);
    int n = 15;
    int res = fibo_lib(n);
    printf("Fibonacci of %d is %d\n",n, res);
  }
  
 return 0;
}
