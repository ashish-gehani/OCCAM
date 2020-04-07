#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int nd_int(){
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



int main(int argc, char* argv[]){

  int r1 = libcall1(nd_int(),nd_int());
  int r2 = libcall2(1,2);
  int r3 = libcall1(3,4);
  int r4 = libcall1(5,6);
  int r5 = libcall1(7,8);  

  printf("%d %d %d %d %d\n", r1,r2,r3,r4,r5);
  return 0;
}
