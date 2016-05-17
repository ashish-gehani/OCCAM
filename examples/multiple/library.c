#include <stdlib.h>
#include <time.h>


static int mystery(){

  srand(time(NULL));

  return rand() ;
}


int libcall_int(int uno, int dos){
  
  if(uno == 0){ return 1; }

  if(uno == 1){ return 2; }

  if(uno == 2){ return 3; }


  return mystery() % (uno + dos);

}



int libcall_float(int uno, float dos, double tres){

  if(dos == 0.5 || tres == 0.5){

    return 7;

  } else {

    return (int)(mystery() * dos * uno);

  }

}

int libcall_string(int uno, const char* dos){

  if(dos != NULL && dos[0] == 'Z' && dos[1] == 0){

    return 11;

  } else {

    return mystery() * uno;

  }
  
}

int libcall_null_pointer(int uno, void * dos){

  if(dos == NULL){
    
    return 5;
    
  } else {

    return mystery() * uno;
 
  }

}

/* to do */
int libcall_global_pointer(int uno, void * dos){
  if(dos == &libcall_global_pointer){

    return 13;
    
  } else {

    return mystery() * uno;

  }
}

