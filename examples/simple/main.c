#include <stdio.h>
#include <stdlib.h>

#include "library.h"


int main(int argc, char* argv[]){
  int retval = 0;
  
  if(argc == 1){
    retval = libcall(argc, argc);
  } else {
    retval = libcall(atol(argv[1]), 1) * libcall(atol(argv[1]), 2);
  } 

  fprintf(stderr, "main returning %d\n", retval);

  return retval;
}
