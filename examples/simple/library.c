#include <stdlib.h>
#include <time.h>

int libcall(int uno, int dos){
  srand(time(NULL));
  
  if(dos == 0){ return 1; }

  if(dos == 1){ return 2; }

  if(dos == 2){ return 3; }

  return rand() % (uno + dos);

}
