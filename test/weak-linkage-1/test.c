int test() {
  return 11;
}

#pragma weak testX = test
int testX(); // __attribute__((weak, alias("test")));
