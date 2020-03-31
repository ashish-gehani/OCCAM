#include "library.h"

int incr(int x) {
  return x+1;
}

int (*get_callback(void))(int) {
  return &incr;
}
