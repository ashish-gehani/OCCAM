// RUN: %cmd "%s"
// RUN: cat "%s".output 2>&1  | FileCheck  "%s"
// CHECK: 2. You should see this message

#include <stdio.h>

extern int nd_int(void);

static int x;   // LIVE INITIALIZATION

void init() {
  if (nd_int()) {
    x = 2;    
  }
}

int main(int argc, char* argv[]) {
  if (argc < 2) {
    return 1;
  }
  
  init();

  if (x == 0 || x == 2) {
    printf("1. You should see this message\n");    
  } else {
    printf("2. You should see this message\n");    
  }
  
  return 0;
}
