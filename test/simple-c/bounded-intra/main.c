#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int nd_int(){
  srand(time(NULL));
  return rand() ;
}


int libcall(int uno, int dos){
  if(uno == 0){ return 1+nd_int(); }
  if(uno == 1){ return 2+nd_int(); }
  if(uno == 2){ return 3+nd_int(); }
  return nd_int();
}



int main(int argc, char* argv[]){

  int x = nd_int();
  int y = nd_int();

  int r1 = libcall(x,y);
  int r2 = libcall(1,2);
  int r3 = libcall(3,4);
  int r4 = libcall(5,6);
  int r5 = libcall(7,8);  

  printf("%d %d %d %d %d\n", r1,r2,r3,r4,r5);
  return 0;
}
