// RUN: %cmd "%s"
// RUN: cat "%s".output 2>&1  | FileCheck  "%s"
// CHECK-NOT: You should not see this message.

/* 
 * Example showing crabopt.
 * The analysis is interprocedural and it infers intervals.
*/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>


int nd_int(void){
  srand(time(NULL));
  return rand() ;
}

void fun1(int a) {
  printf("Value of a is %d\n", a);
}
void fun2(int a) {
  printf("Value of a is %d\n", a+1);
}
void fun3(int a) {
  printf("You shoud not see this. Value of a is %d\n", a+2);
}

void (*fun_ptr)(int) = fun3;

int main() {

   int x = nd_int();
   if (x < 0) return 0;
		
   if (x > 0)
     fun_ptr = fun1;
   else
     fun_ptr = fun2;

   if (x < 0) fun_ptr = fun3;
   
   (*fun_ptr)(x);
   return 0;
}

