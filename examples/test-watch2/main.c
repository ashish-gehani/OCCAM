#include <unistd.h>
#include <stdio.h>

int
foo(int x)
{
  if (x == 3) {
    printf("processing...\n");
    sleep(3);
  } else {
    printf("processing...\n");
    sleep(1);
  }
  return x * x;
}

int
main(int argc, char* argv[])
{
  for (int i = 0; i < 5; i++) {
    foo(i);
  }
}
