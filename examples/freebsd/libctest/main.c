#include "stdio.h"

int main(int argc, char *argv[]) {
  for (unsigned int i=0; i<argc; ++i) {
    puts(argv[i]);
  }
}
