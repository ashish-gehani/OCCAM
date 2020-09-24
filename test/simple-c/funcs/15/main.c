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
// We don't remove decr because we still store in *fun1
int decr(int) {..}

int decr_5() { return 4; }

main() {
   res = execute_call_decr_5();
}

=== SPECIALIZED LIBRARY ===
int execute_call_decr_5() {
  return decr_5();
}
****/
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

  /// LIMITATION: We cannot remove this code and therefore the
  /// functions decr and square even if they are actually dead after
  /// we created specialized copies.
  *fun1 = &decr;
  *fun2 = &square;
}

int main() {
  init();
  // *fun2 = {&square}
  int x = (*fun2)(7);
  // *fun1 = {&decr}
  int y = execute_call(*fun1, 5);
  printf("%d\n",x+y);
  return 0;
}
