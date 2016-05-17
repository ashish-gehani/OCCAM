#include <stdio.h>
#include <stdlib.h>

#include "library.h"

int global = 666;

int main(int argc, char* argv[]){
  int retval = 0;


  if(argc == 1){


  } else if(argc == 2){

    /* retval =  2  *  3 */
    retval =
      libcall_int(1, atol(argv[1]))    *         // 2
      libcall_int(2, atol(argv[1]))    *         // 3
      libcall_float(3, 0.5, 0.5)       *         // 7
      libcall_null_pointer(4, NULL)    *         // 5
      libcall_string(5, "Z")           *         // 11
      libcall_global_pointer(6, &libcall_global_pointer);

  } else {

    retval = libcall_int(argc, argc);

  }


  fprintf(stderr, "main returning %d\n", retval);

  return retval;
}
