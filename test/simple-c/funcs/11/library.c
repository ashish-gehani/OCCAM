#include "library.h"

int execute_call(FN_PTR func, int x) {
  return func(x);
}
