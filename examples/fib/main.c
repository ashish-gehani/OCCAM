#include <stdio.h>
#include <stdlib.h>

int fibo(int x) {
  if (x <= 1) {
    return x;
  } else {
    return fibo(x-1) + fibo(x-2);
  }
}

int main(int argc, char* argv[]){
  if (argc == 2) {
    // Currently, user-input specialization does not understand
    // library calls such as atoi.
    //int n = atoi(argv[1]);
    int n = 15;
    int res = fibo(n);
    printf("Fibonacci of %d is %d\n",n, res);
  }
  
 return 0;
}
