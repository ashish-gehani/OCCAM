#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "library.h"

/* This example requires to understand atol */

int main(int argc, char* argv[]){
  int retval = 0;
  int (*f) (int, int) = NULL;

  printf("Number of input arguments: %d\n",argc);
  printf("Initial retval=%d\n",retval);
  
  if(argc == 1){


  } else if(argc == 4){
    if (atol(argv[1]) == 1) {
      f = &add_one;
      printf ("add_one is called\n");
    }
    else if (atol(argv[1]) == 2) {
      f = &add_two;
      printf ("add_two is called\n");      
    } else if (atol(argv[1]) == 3) {
      f = &add_three;
      printf ("add_three is called\n");            
    } else {
      
    }

    if (f)
      retval = f(atol(argv[2]),atol(argv[3]));
    
  } else {
    
  }
  printf("Final retval=%d\n",retval);
  return retval;
}
