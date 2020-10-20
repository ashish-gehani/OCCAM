#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct mime_entry {
    char* ext;
    size_t ext_len;
    char* val;
    size_t val_len;
    };

static struct mime_entry enc_tab[] = {
  { "Z", 0, "compress", 0 },
  { "gz", 0, "gzip", 0 }
};

static const int n_enc_tab = sizeof(enc_tab) / sizeof(*enc_tab);

static int
ext_compare( a, b )
    struct mime_entry* a;
    struct mime_entry* b;
    {
      return strcmp( a->ext, b->ext );
    }

int main (int argc, char **argv){
  qsort( enc_tab, n_enc_tab, sizeof(*enc_tab), ext_compare );
  return 0;
}
