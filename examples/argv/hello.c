#include <stdio.h>

int main(int argc, char *argv[]) {
  if(argc > 1){
    printf("Hello %s!\n", argv[1]);
  } else {
    printf("Hello!\n");
  }


  for(int i = 0; i < argc; i++){

    printf(argv[i]);

  }


  return 0;
}
