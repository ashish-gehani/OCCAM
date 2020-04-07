#include <stdio.h>
#include "library.h"

/*
  Similar to funcs/4 but init_callbacks and equal_str are defined in a
  library. This example is very challenging and it's currently beyond
  what OCCAM can do. First, we cannot reason about string contents so
  we won't be able to tell whether argv[1] is "one", "two" or
  "three". Second, the array cb is populated in the library. OCCAM's
  inter-module specialization cannot propagate the contents of cb so
  we won't know which functions are being called.
 */
extern void init_callbacks (int (**cb)(int, int));
extern int equal_str (const char* s1, const char* s2);

int main(int argc, char* argv[]){
  int retval = 0;
  int (*cb[3])(int, int);

  init_callbacks (&cb);

  if(argc == 1){

  } else if(argc == 2){
    if (equal_str(argv[1], "one")) {
      retval = cb[0] (argc+2,argc);
      
    } else if (equal_str(argv[1],"two")) {
      retval = cb[1] (argc+3,argc);
      
    } else if (equal_str(argv[1],"three")) {
      retval = cb[2] (argc+4,argc);
      
    } else {
      
    }
  }
  printf("Final retval=%d\n",retval);
  return retval;
}
