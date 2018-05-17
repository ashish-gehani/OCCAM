//If ipdse pass is enabled then we should see only one of the messages.
#include <stdio.h>

extern int x;
extern int y;
extern void init_x(void);
extern void init_y(void);

int main(int argc, char* argv[]) {
  y = 3;        // DEAD STORE
  init_x();     // DEAD STORE
  init_y();     // LIVE STORE
  x = 4;        // LIVE STORE

  if (y != 1) {
    printf("1. You should not see this message\n");
  }

  if (x != 4) {
    printf("2. You should not see this message\n");    
  }

  if (y == 1) {
    printf("3. You should see this message\n");    
  }
  
  return 0;
}
