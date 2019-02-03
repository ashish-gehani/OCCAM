#include <stdio.h>
#include "library.h"


int main() {
  int (*f)(int) = get_callback();
  return f(5);
}
