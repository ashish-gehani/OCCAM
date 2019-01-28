/* Example from https://llvm.org/docs/LinkTimeOptimization.html */

#include <stdio.h>
#include "library.h"

void foo4(void) {
  printf("Hi\n");
}

int main() {
  return foo1();
}

