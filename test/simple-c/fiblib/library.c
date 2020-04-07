#include <stdlib.h>

int fibo_lib(int x) {
  if (x <= 1) {
    return x;
  } else {
    return fibo_lib(x-1) + fibo_lib(x-2);
  }
}

