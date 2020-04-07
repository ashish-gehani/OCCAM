#include <stdio.h>
#include "library.h"

int incr(int x) {
  return x+1;
}

/* 
   Without pointer analysis llvm cannot reason about fun.  

   Even with pointer analysis, we need to propagate that *fun = &incr
   at the callsite of execute_call.  Note that we don't create a
   bounce function for *fun since it's never called. So even if we
   know that *fun = &incr we don't say that explicitly so it's never
   propagated through inter-module specialization.
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
