#include <stdio.h>
#include "library.h"

// OCCAM misses library functions defined in main.

void foo4(void) {
  printf("Hi\n");
}

int main() {
  return foo1();
}
