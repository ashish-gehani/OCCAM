#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>




extern int64_t memcmp(int64_t a, int64_t b, int64_t l); 




int main(int argc, char* argv[]){

  if(argc == 4){
    return memcmp(argv[1], argv[2], atoi(argv[3]));
  } else {
    fprintf(stderr, "Usage: %s <str0> <str1> <len>\n", argv[0]);
    return 1;
  }

}
