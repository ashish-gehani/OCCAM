#include <stdio.h>
#include <stdlib.h>

#include "library.h"

#include "module.h"


int main(int argc, char* argv[]){
  int retval = 0;
  
  if(argc != 2){
    retval = libcall(argc, argc);
  } else {
    /* retval =  2  *  3 */
    retval =
      libcall(atol(argv[1]), 1) *
      libcall(atol(argv[1]), 2) *
      internal_api(3, argv[1], "Z") *
      internal_api(4, NULL, argv[1]) *
      internal_api(5, argv[1], argv[1])
      ;
  } 

  fprintf(stderr, "main returning %d\n", retval);

  return retval;
}

/*

  int internal_api(int, void*, char*);

*/
