#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int nd_int(){
  srand(time(NULL));
  return rand() ;
}

int incr(int x) {
  return x+1;
}

int decr(int x) {
  return x-1;
}

/* 
   Example of multiple callees for an indirect call
*/

typedef int (*FN_PTR)(int);

FN_PTR _fun;
FN_PTR* fun = &_fun;

void init() {
  if (nd_int())
    *fun = &incr;
  else
    *fun = &decr;    
}

int main() {
  init();
  int res = (*fun)(5);
  if (res == 6) {
    printf("the incr function was called\n");
  } else {
    printf("the decr function was called\n");
  }
  return 0;
}
