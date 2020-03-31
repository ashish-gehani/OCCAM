#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "library.h"

void __attribute__((always_inline)) init_callbacks (int (**cb)(int, int)) {
  cb[0] = &add_one;
  cb[1] = &add_two;
  cb[2] = &add_three;
}

int main(int argc, char* argv[]){
  int retval = 0;
  int (*cb[3])(int, int);

  init_callbacks (&cb);

  if(argc == 1){

  } else if(argc == 2){ 
    retval = cb[0] (argc+2,argc);
    printf ("add_one is called\n");
  } else if (argc == 3) {
    retval = cb[1] (argc+3,argc);
    printf ("add_two is called\n");      
  } else if (argc == 4) {
    retval = cb[2] (argc+4,argc);
    printf ("add_three is called\n");            
  } else {
    
  }

  printf("Final retval=%d\n",retval);
  return retval;
}
