#include <stdio.h>
#include "library.h"

int incr(int x) {
  return x+1;
}

/* 
   Good example showing occam's capabilities.

   execute_call is fully specialized because both arguments can be
   known statically (the first argument can be only known through
   seadsa).
*/

FN_PTR _fun;
FN_PTR* fun = &_fun;

void init() {
  *fun = &incr;
}

int main() {
  init();
  int res = execute_call(*fun, 5);
  if (res == 6) {
    printf("you should see this message\n");
  } else {
    printf("you should NOT see this message\n");
  }
  return 0;
}
