#include <stdio.h>
#include <stdlib.h>

#if 1
size_t __attribute__((always_inline)) mystrlen(const char * str)
{
    const char *s;
    for (s = str; *s; ++s) {}
    return(s - str);
}

int __attribute__((always_inline)) mystrncmp(const char* s1, const char* s2, size_t n)
{
    while(n--)
        if(*s1++!=*s2++)
            return *(unsigned char*)(s1 - 1) - *(unsigned char*)(s2 - 1);
    return 0;
}

int __attribute__((always_inline)) equal_str (const char* s1, const char* s2) {
  int min_len = (mystrlen(s1) < mystrlen(s2) ? mystrlen(s1) : mystrlen(s2));
  return (mystrncmp(s1,s2,min_len) == 0);
}
#else 
int __attribute__((always_inline)) equal_str(const char* s1, const char* s2)
{
  while(*s1 && (*s1==*s2))
    s1++,s2++;
  return *(const unsigned char*)s1-*(const unsigned char*)s2;
}
#endif 
