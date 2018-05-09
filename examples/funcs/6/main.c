#include <stdio.h>
#include <stdlib.h>

#include "library.h"
#include "mystring.h"

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
