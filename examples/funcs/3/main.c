#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "library.h"

int __attribute__((always_inline)) equal_str (const char* s1, const char* s2) {
  int min_len = (strlen(s1) < strlen(s2) ? strlen(s1) : strlen(s2));
  return (strncmp(s1,s2,min_len) == 0);
}

int main(int argc, char* argv[]){
  int retval = 0;
  int (*f) (int, int) = NULL;

  if(argc == 1){

  } else if (argc == 2) {
    if (equal_str(argv[1], "one")) { 
      f = &add_one;
    } else if (equal_str(argv[1],"two")) {
      f = &add_two;
    } else if (equal_str(argv[1],"three")) {
      f = &add_three;
    } else {
      
    }
  } else {

  }

  if (f) {
    retval = f(argc+3, argc);
  } else {
  }
  
  printf("Final retval=%d\n",retval);
  return retval;
}
