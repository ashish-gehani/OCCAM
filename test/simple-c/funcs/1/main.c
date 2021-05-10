#include "stdio.h"
/*
  JN: we don't get the expected results because argv[0] is lowered as
  a non-constant global variable and this precludes some important
  LLVM optimizations. This can be solved by using sea-dsa and make
  const those globals that are never modified.
 */
extern int call(int (*fn)(int, char *), int, char *);

static int test(int i, char *str) {
  if (i == 1) {
    printf("%s\n", str);
    return 0;
  } else {
    printf("Nope!\n");
    return -1;
  }
}

int main(int argc, char *argv[]) {
  return call(test,argc,argv[0]);
}
