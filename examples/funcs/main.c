#include "stdio.h"

extern int call(int (*fn)(int, char *), int, char *);

static int test(int i, char *str) {
  if (i == 1) {
    printf("No command line arguments for %s\n", str);
    return 0;
  } else {
    printf("Number of command line arguments: %d\n",i);
    return -1;
  }
}

int main(int argc, char *argv[]) {
  return call(test,argc,argv[0]);
}
