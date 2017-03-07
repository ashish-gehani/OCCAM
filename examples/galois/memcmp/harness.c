#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>


int64_t F4004ec(int64_t s0, int64_t s1, int64_t len);



int main(int argc, char* argv[]){

  if(argc != 4){
    fprintf(stderr, "Usage %s <string 1> <string 2>  <length>\n", argv[0]);
    return 1;
  }
  

  return F4004ec((int64_t)argv[1], (int64_t)argv[2], (int64_t)atol(argv[3]));


}


