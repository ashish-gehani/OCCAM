#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "library.h"

int main(int argc, char* argv[]){
  int retval = 0;
  int (*f) (int, int) = NULL;

  if(argc == 1){

  } else if(argc == 2){ 
    f = &add_one;
    printf ("add_one is called\n");
  } else if (argc == 3) {
    f = &add_two;
    printf ("add_two is called\n");      
  } else if (argc == 4) {
    f = &add_three;
    printf ("add_three is called\n");            
  } else {
    
  }

  if (f) {
    retval = f(argc, argc);
  } else {
  }
  
  printf("Final retval=%d\n",retval);
  return retval;
}
