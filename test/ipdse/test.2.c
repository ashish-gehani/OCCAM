// RUN: %cmd "%s"
// RUN: cat "%s".output 2>&1  | FileCheck  "%s"
// CHECK-NOT: You should not see this message

#include <stdio.h>

extern int nd_int(void);

static int x;   // DEAD INITIALIZATION
static int y;   // DEAD INITIALIZATION

int init() {
  y = 1;    // LIVE STORE
  if (nd_int()) {
    x = 2;  // DEAD STORE
  } else {
    x = 5;  // DEAD STORE
  }
  return y;
}

int main(int argc, char* argv[]) {
  if (argc < 2) {
    return 1;
  }
  
  y = 3;  // DEAD STORE
  int r = init();
  x = 4;  // LIVE STORE

  if (y != 1) {
    printf("1. You should not see this message\n");
  }

  if (x != 4) {
    printf("2. You should not see this message\n");    
  }

  if (y == 1) {
    printf("3. You should see this message\n");    
  }
  
  return 0;
}
