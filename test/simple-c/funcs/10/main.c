#include <stdio.h>
#include "library.h"

int incr(int x) {
  return x+1;
}

/* 
   No need of pointer analysis.

   The function incr is specialized thanks to inter-module
   specialization.  However, the message "you should NOT see this
   message\n" is still in the slashed bitcode because we don't
   propagate return values across LLVM modules.
 */

int main() {
  int res = execute_call(&incr, 5);
  if (res == 6) {
    printf("you should see this message\n");
  } else {
    printf("you should NOT see this message\n");
  }
  return 0;
}
