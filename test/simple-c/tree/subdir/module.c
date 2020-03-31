#include <stdint.h>
#include <stdlib.h>

/*
      internal_api(3, argv[1], "Z") *
      internal_api(4, null, argv[1]) *
      internal_api(5, argv[1], argv[1])

*/

int internal_api(int i, void* p, char* s){
  if( (i == 5) ||
      (p == NULL)  ||
      (s != NULL && s[0] == 'Z' && s[1] == 0) ){
    return 666;
  } else {

    return (int)(((uintptr_t) p + (uintptr_t) s) / 2);




  }
  
}
