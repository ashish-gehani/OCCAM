#include <stdio.h>
#include "library.h"
/*
  We cannot resolve the indirect call because the inter-specialization
  process does not propagate return values from library calls.
 */

int main() {
  int (*f)(int) = get_callback();
  return f(5);
}
