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

typedef struct state {
  int x;
  int y;
} State;

void read(int argc, char* argv[], State *s) {
  
  if (nd_int()) {
    s->x = 1;
  } else if (nd_int()) {
    s->x = 2;
  } else if (nd_int()) {
    s->x = 4;
  } else {
    s->x = 5;
  }
}

void process(State *s) {
  if (s->x == 7) {
    printf("You should not see this message.");
  }
  if (s->x == 3) {
    printf("You should not see this message but analysis not precise enough.");    
  }
  if (s->x == 0) {
    printf("You should not see this message.");    
  }
  if (s->x == 2) {
    printf("You should see this message.");    
  }
}

int main(int argc, char* argv[]) {
  State s;
  read(argc, argv, &s);
  process(&s);
  return 0;
}


