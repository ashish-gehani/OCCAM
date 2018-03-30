/**
 * Read the contents of the open file <b>fd</b> presuming it is a FIFO
 * (or similar) file descriptor for which the size of the file isn't
 * known ahead of time. Return NULL on failure, and a NUL-terminated
 * string on success.  On success, set <b>sz_out</b> to the number of
 * bytes read.
 */
char *
read_file_to_str_until_eof(int fd, size_t max_bytes_to_read, size_t *sz_out)
{
  ssize_t r;
  size_t pos = 0;
  char *string = NULL;
  size_t string_max = 0;

  if (max_bytes_to_read+1 >= SIZE_T_CEILING) {
    errno = EINVAL;
    return NULL;
  }

  do {
    /* XXXX This "add 1K" approach is a little goofy; if we care about
     * performance here, we should be doubling.  But in practice we shouldn't
     * be using this function on big files anyway. */
    string_max = pos + 1024;
    if (string_max > max_bytes_to_read)
      string_max = max_bytes_to_read + 1;
    string = tor_realloc(string, string_max);
    r = read(fd, string + pos, string_max - pos - 1);
    if (r < 0) {
      int save_errno = errno;
      tor_free(string);
      errno = save_errno;
      return NULL;
    }

    pos += r;
  } while (r > 0 && pos < max_bytes_to_read);

  tor_assert(pos < string_max);
  *sz_out = pos;
  string[pos] = '\0';
  return string;
}

/** Read the contents of <b>filename</b> into a newly allocated
 * string; return the string on success or NULL on failure.
 *
 * If <b>stat_out</b> is provided, store the result of stat()ing the
 * file into <b>stat_out</b>.
 *
 * If <b>flags</b> &amp; RFTS_BIN, open the file in binary mode.
 * If <b>flags</b> &amp; RFTS_IGNORE_MISSING, don't warn if the file
 * doesn't exist.
 */
/*
 * This function <em>may</em> return an erroneous result if the file
 * is modified while it is running, but must not crash or overflow.
 * Right now, the error case occurs when the file length grows between
 * the call to stat and the call to read_all: the resulting string will
 * be truncated.
 */
MOCK_IMPL(char *,
read_file_to_str, (const char *filename, int flags, struct stat *stat_out))
{
  int fd; /* router file */
  struct stat statbuf;
  char *string;
  ssize_t r;
  int bin = flags & RFTS_BIN;

  tor_assert(filename);

  fd = tor_open_cloexec(filename,O_RDONLY|(bin?O_BINARY:O_TEXT),0);
  if (fd<0) {
    int severity = LOG_WARN;
    int save_errno = errno;
    if (errno == ENOENT && (flags & RFTS_IGNORE_MISSING))
      severity = LOG_INFO;
    log_fn(severity, LD_FS,"Could not open \"%s\": %s",filename,
           strerror(errno));
    errno = save_errno;
    return NULL;
  }

  if (fstat(fd, &statbuf)<0) {
    int save_errno = errno;
    close(fd);
    log_warn(LD_FS,"Could not fstat \"%s\".",filename);
    errno = save_errno;
    return NULL;
  }

#ifndef _WIN32
/** When we detect that we're reading from a FIFO, don't read more than
 * this many bytes.  It's insane overkill for most uses. */
#define FIFO_READ_MAX (1024*1024)
  if (S_ISFIFO(statbuf.st_mode)) {
    size_t sz = 0;
    string = read_file_to_str_until_eof(fd, FIFO_READ_MAX, &sz);
    int save_errno = errno;
    if (string && stat_out) {
      statbuf.st_size = sz;
      memcpy(stat_out, &statbuf, sizeof(struct stat));
    }
    close(fd);
    if (!string)
      errno = save_errno;
    return string;
  }
#endif /* !defined(_WIN32) */

  if ((uint64_t)(statbuf.st_size)+1 >= SIZE_T_CEILING) {
    close(fd);
    errno = EINVAL;
    return NULL;
  }

  string = tor_malloc((size_t)(statbuf.st_size+1));

  r = read_all(fd,string,(size_t)statbuf.st_size,0);
  if (r<0) {
    int save_errno = errno;
    log_warn(LD_FS,"Error reading from file \"%s\": %s", filename,
             strerror(errno));
    tor_free(string);
    close(fd);
    errno = save_errno;
    return NULL;
  }
  string[r] = '\0'; /* NUL-terminate the result. */

#if defined(_WIN32) || defined(__CYGWIN__)
  if (!bin && strchr(string, '\r')) {
    log_debug(LD_FS, "We didn't convert CRLF to LF as well as we hoped "
              "when reading %s. Coping.",
              filename);
    tor_strstrip(string, "\r");
    r = strlen(string);
  }
  if (!bin) {
    statbuf.st_size = (size_t) r;
  } else
#endif /* defined(_WIN32) || defined(__CYGWIN__) */
    if (r != statbuf.st_size) {
      /* Unless we're using text mode on win32, we'd better have an exact
       * match for size. */
      int save_errno = errno;
      log_warn(LD_FS,"Could read only %d of %ld bytes of file \"%s\".",
               (int)r, (long)statbuf.st_size,filename);
      tor_free(string);
      close(fd);
      errno = save_errno;
      return NULL;
    }
  close(fd);
  if (stat_out) {
    memcpy(stat_out, &statbuf, sizeof(struct stat));
  }

  return string;
}
