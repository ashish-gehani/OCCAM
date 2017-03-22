int call(int (*fn)(int, char *), int i, char *str) {
  return fn(i,str);
}
