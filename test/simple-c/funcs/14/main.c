#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "library.h"

/****

=== APP ===
int incr(int) {..}
int decr(int) {..}
main() {
  FUN_PTR *f = choose_nd(incr, decr, ...)
  int res = execute_call(*f, 5);
}


=== LIBRARY ===
execute_call(FUN_PTR, int)


=== SPECIALIZED APP ===
// we don't remove incr/decr because we still need to compare with its
// address.
int incr(int) {..} 
int decr(int) {..}

int incr_5() { return 6; }
int decr_5() { return 4; }

main() {
  FUN_PTR *f = choose_nd(incr, decr, ...)
  if (f == &incr) {
     res = execute_call_incr_5();
  } else if (f == &decr) {
     res = execute_call_decr_5();
  } else {
    ...
  }

=== SPECIALIZED LIBRARY ===

int execute_call_incr_5() {
  return incr_5();
}
int execute_call_decr_5() {
  return decr_5();
}
****/
int nd_int(){
  srand(time(NULL));
  return rand() ;
}


// LIMITATIONS: We cannot remove this function even if it's dead after
// we make a specialized copy.  There are two reasons: (1) we use
// &incr in the code that lower a function pointer parameter and (2)
// there is a store of &incr int *fun1.
int incr(int x) {
  return x+1;
}

// LIMITATIONS: same problems as incr.
int decr(int x) {
  return x-1;
}

int square(int x) {
  return x*x;
}

typedef int (*FN_PTR)(int);

FN_PTR _fun1;
FN_PTR* fun1 = &_fun1;

FN_PTR _fun2;
FN_PTR* fun2 = &_fun2;

void init() {
  while(nd_int()); // loop to avoid init to be inlined
  
  if (nd_int())
    *fun1 = &incr;
  else
    *fun1 = &decr;

  *fun2 = &square;
}

int main() {
  init();
  int x = (*fun2)(7);
  int y = execute_call(*fun1, 5);
  printf("%d\n",x+y);
  return 0;
}
