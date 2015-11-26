#include <stdio.h>
#include <time.h>

static time_t start_time;

void
enter_foo(int x)
{
  printf(" >> foo(%d)\n", x);
  start_time = time(NULL);
}

void
exit_foo(int x, int y)
{
  time_t end_time = time(NULL);
  double diff = difftime(end_time, start_time);
  printf(" << foo(%d) => %d [%.2fs]\n", x, y, diff);
}
