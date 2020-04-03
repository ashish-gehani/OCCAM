#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int nd_int(){
  srand(time(NULL));
  return rand() ;
}

int flag_a = 0;
int flag_b = 0;
int flag_c = 0;

/* 
 * We use a fully instantiated manifest.
 *
 * We shouldn't remove messages "You should NOT see this message"
 * since modify_flags is called before use_flags.
*/

void modify_flags() {
  if(nd_int()) {
    flag_b = 0;
    flag_a = 1;
  }
}

void get_opt(int argc, char **argv) {
  // assigning a literal value 1 to each flag
  unsigned iter;
  for(iter = 1; iter < argc; iter++){
    if(argv[iter][0] == '-' && argv[iter][1]){ 
      switch(argv[iter][1]){ 
      case 'a':
	flag_a = 1; 
	  break;
      case 'b':
	flag_b = 1;
	break;
      case 'c':
	flag_c = 1;
	break;
	default:
	  break;
      }
    }
  }
}

void use_flags() {
  if (flag_b) {
    printf("You should see this message\n");
  }
  if (flag_a) {
    printf("You should NOT see this message\n");
  }
  if (flag_c) {
    printf("You should NOT see this message\n");
  }
  
}

int main (int argc, char **argv){
  get_opt(argc, argv);
  modify_flags();
  use_flags();
  
  return 0;
}
