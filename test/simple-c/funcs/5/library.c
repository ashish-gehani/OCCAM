#include <stdlib.h>
#include <string.h>

int add_one(int x, int y){
  return x+1;
}

int add_two(int x, int y){
  return x+2;
}

int add_three(int x, int y){
  return x+3;
}

void init_callbacks (int (**cb)(int, int)) {
  cb[0] = &add_one;
  cb[1] = &add_two;
  cb[2] = &add_three;
}

int equal_str (const char* s1, const char* s2) {
  int min_len = (strlen(s1) < strlen(s2) ? strlen(s1) : strlen(s2));
  return (strncmp(s1,s2,min_len) == 0);
}
