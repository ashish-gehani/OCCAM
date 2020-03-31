#include <stdlib.h>
#include <time.h>

static int nd_int(){
  srand(time(NULL));
  return rand() ;
}

int libcall1(int uno, int dos){
  if(uno == 0){ return 1+nd_int(); }
  if(uno == 1){ return 2+nd_int(); }
  if(uno == 2){ return 3+nd_int(); }
  return nd_int();
}

int libcall2(int uno, int dos){
  if(uno == 0){ return 1+nd_int(); }
  if(uno == 1){ return 2+nd_int(); }
  if(uno == 2){ return 3+nd_int(); }
  return nd_int();
}

