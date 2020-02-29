int test() {
  return 11;
}

#pragma weak __test = test
int __test (); // __attribute__((weak, alias("test")));
