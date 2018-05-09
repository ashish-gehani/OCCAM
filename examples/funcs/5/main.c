#include <stdio.h>
#include "library.h"

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
