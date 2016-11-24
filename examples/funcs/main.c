#include "stdio.h"

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
