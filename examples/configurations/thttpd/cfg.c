#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>

//<iam's addition's>
//make this smaller and you will see a bug in the design of the read_config function.
#define CFG_CHUNK 10000
static void dump_config(FILE*);
//<iam's addition's>

#define DEFAULT_CHARSET "UTF-8"
#define DEFAULT_USER "nobody"
#define DEFAULT_PORT 80
#define SERVER_SOFTWARE "thttpd/2.27 19Oct2015"


static char* argv0;
static int debug;
static unsigned short port;
static char* dir;
static char* data_dir;
static int do_chroot, no_log, no_symlink_check, do_vhost, do_global_passwd;
static char* cgi_pattern;
static int cgi_limit;
static char* url_pattern;
static int no_empty_referrers;
static char* local_pattern;
static char* logfile;
static char* throttlefile;
static char* hostname;
static char* pidfile;
static char* user;
static char* charset;
static char* p3p;
static int max_age;

static void parse_args( int argc, char** argv );
static void usage( void );
static void read_config( char* filename );
static void value_required( char* name, char* value );
static void no_value_required( char* name, char* value );
static char* e_strdup( char* oldstr );

int
main( int argc, char** argv )
    {
      /* Handle command-line arguments. */
      parse_args( argc, argv );

      dump_config(stderr);

      return 0;
    }


static void
parse_args( int argc, char** argv )
    {
    int argn;

    debug = 0;
    port = DEFAULT_PORT;
    dir = (char*) 0;
    data_dir = (char*) 0;
#ifdef ALWAYS_CHROOT
    do_chroot = 1;
#else /* ALWAYS_CHROOT */
    do_chroot = 0;
#endif /* ALWAYS_CHROOT */
    no_log = 0;
    no_symlink_check = do_chroot;
#ifdef ALWAYS_VHOST
    do_vhost = 1;
#else /* ALWAYS_VHOST */
    do_vhost = 0;
#endif /* ALWAYS_VHOST */
#ifdef ALWAYS_GLOBAL_PASSWD
    do_global_passwd = 1;
#else /* ALWAYS_GLOBAL_PASSWD */
    do_global_passwd = 0;
#endif /* ALWAYS_GLOBAL_PASSWD */
#ifdef CGI_PATTERN
    cgi_pattern = CGI_PATTERN;
#else /* CGI_PATTERN */
    cgi_pattern = (char*) 0;
#endif /* CGI_PATTERN */
#ifdef CGI_LIMIT
    cgi_limit = CGI_LIMIT;
#else /* CGI_LIMIT */
    cgi_limit = 0;
#endif /* CGI_LIMIT */
    url_pattern = (char*) 0;
    no_empty_referrers = 0;
    local_pattern = (char*) 0;
    throttlefile = (char*) 0;
    hostname = (char*) 0;
    logfile = (char*) 0;
    pidfile = (char*) 0;
    user = DEFAULT_USER;
    charset = DEFAULT_CHARSET;
    p3p = "";
    max_age = -1;
    argn = 1;
    while ( argn < argc && argv[argn][0] == '-' )
	{
	if ( strcmp( argv[argn], "-V" ) == 0 )
	    {
	    (void) printf( "%s\n", SERVER_SOFTWARE );
	    exit( 0 );
	    }
	else if ( strcmp( argv[argn], "-C" ) == 0 && argn + 1 < argc )
	    {
	    ++argn;
	    read_config( argv[argn] );
	    }
	else if ( strcmp( argv[argn], "-p" ) == 0 && argn + 1 < argc )
	    {
	    ++argn;
	    port = (unsigned short) atoi( argv[argn] );
	    }
	else if ( strcmp( argv[argn], "-d" ) == 0 && argn + 1 < argc )
	    {
	    ++argn;
	    dir = argv[argn];
	    }
	else if ( strcmp( argv[argn], "-r" ) == 0 )
	    {
	    do_chroot = 1;
	    no_symlink_check = 1;
	    }
	else if ( strcmp( argv[argn], "-nor" ) == 0 )
	    {
	    do_chroot = 0;
	    no_symlink_check = 0;
	    }
	else if ( strcmp( argv[argn], "-dd" ) == 0 && argn + 1 < argc )
	    {
	    ++argn;
	    data_dir = argv[argn];
	    }
	else if ( strcmp( argv[argn], "-s" ) == 0 )
	    no_symlink_check = 0;
	else if ( strcmp( argv[argn], "-nos" ) == 0 )
	    no_symlink_check = 1;
	else if ( strcmp( argv[argn], "-u" ) == 0 && argn + 1 < argc )
	    {
	    ++argn;
	    user = argv[argn];
	    }
	else if ( strcmp( argv[argn], "-c" ) == 0 && argn + 1 < argc )
	    {
	    ++argn;
	    cgi_pattern = argv[argn];
	    }
	else if ( strcmp( argv[argn], "-t" ) == 0 && argn + 1 < argc )
	    {
	    ++argn;
	    throttlefile = argv[argn];
	    }
	else if ( strcmp( argv[argn], "-h" ) == 0 && argn + 1 < argc )
	    {
	    ++argn;
	    hostname = argv[argn];
	    }
	else if ( strcmp( argv[argn], "-l" ) == 0 && argn + 1 < argc )
	    {
	    ++argn;
	    logfile = argv[argn];
	    }
	else if ( strcmp( argv[argn], "-v" ) == 0 )
	    do_vhost = 1;
	else if ( strcmp( argv[argn], "-nov" ) == 0 )
	    do_vhost = 0;
	else if ( strcmp( argv[argn], "-g" ) == 0 )
	    do_global_passwd = 1;
	else if ( strcmp( argv[argn], "-nog" ) == 0 )
	    do_global_passwd = 0;
	else if ( strcmp( argv[argn], "-i" ) == 0 && argn + 1 < argc )
	    {
	    ++argn;
	    pidfile = argv[argn];
	    }
	else if ( strcmp( argv[argn], "-T" ) == 0 && argn + 1 < argc )
	    {
	    ++argn;
	    charset = argv[argn];
	    }
	else if ( strcmp( argv[argn], "-P" ) == 0 && argn + 1 < argc )
	    {
	    ++argn;
	    p3p = argv[argn];
	    }
	else if ( strcmp( argv[argn], "-M" ) == 0 && argn + 1 < argc )
	    {
	    ++argn;
	    max_age = atoi( argv[argn] );
	    }
	else if ( strcmp( argv[argn], "-D" ) == 0 )
	    debug = 1;
	else
	    usage();
	++argn;
	}
    if ( argn != argc )
	usage();
    }


static void
usage( void )
    {
    (void) fprintf( stderr,
"usage:  %s [-C configfile] [-p port] [-d dir] [-r|-nor] [-dd data_dir] [-s|-nos] [-v|-nov] [-g|-nog] [-u user] [-c cgipat] [-t throttles] [-h host] [-l logfile] [-i pidfile] [-T charset] [-P P3P] [-M maxage] [-V] [-D]\n",
	argv0 );
    exit( 1 );
    }

static void
read_config( char* filename )
    {
    FILE* fp;
    char line[CFG_CHUNK];
    char* cp;
    char* cp2;
    char* name;
    char* value;

    fp = fopen( filename, "r" );
    if ( fp == (FILE*) 0 )
	{
	perror( filename );
	exit( 1 );
	}

    while ( fgets( line, sizeof(line), fp ) != (char*) 0 )
	{
	/* Trim comments. */
	if ( ( cp = strchr( line, '#' ) ) != (char*) 0 )
	    *cp = '\0';

	/* Skip leading whitespace. */
	cp = line;
	cp += strspn( cp, " \t\n\r" );

	/* Split line into words. */
	while ( *cp != '\0' )
	    {
	    /* Find next whitespace. */
	    cp2 = cp + strcspn( cp, " \t\n\r" );
	    /* Insert EOS and advance next-word pointer. */
	    while ( *cp2 == ' ' || *cp2 == '\t' || *cp2 == '\n' || *cp2 == '\r' )
		*cp2++ = '\0';
	    /* Split into name and value. */
	    name = cp;
	    value = strchr( name, '=' );
	    if ( value != (char*) 0 )
		*value++ = '\0';
	    /* Interpret. */
	    if ( strcasecmp( name, "debug" ) == 0 )
		{
		no_value_required( name, value );
		debug = 1;
		}
	    else if ( strcasecmp( name, "port" ) == 0 )
		{
		value_required( name, value );
		port = (unsigned short) atoi( value );
		}
	    else if ( strcasecmp( name, "dir" ) == 0 )
		{
		value_required( name, value );
		dir = e_strdup( value );
		}
	    else if ( strcasecmp( name, "chroot" ) == 0 )
		{
		no_value_required( name, value );
		do_chroot = 1;
		no_symlink_check = 1;
		}
	    else if ( strcasecmp( name, "nochroot" ) == 0 )
		{
		no_value_required( name, value );
		do_chroot = 0;
		no_symlink_check = 0;
		}
	    else if ( strcasecmp( name, "data_dir" ) == 0 )
		{
		value_required( name, value );
		data_dir = e_strdup( value );
		}
	    else if ( strcasecmp( name, "nosymlinkcheck" ) == 0 )
		{
		no_value_required( name, value );
		no_symlink_check = 1;
		}
	    else if ( strcasecmp( name, "symlinkcheck" ) == 0 )
		{
		no_value_required( name, value );
		no_symlink_check = 0;
		}
	    else if ( strcasecmp( name, "user" ) == 0 )
		{
		value_required( name, value );
		user = e_strdup( value );
		}
	    else if ( strcasecmp( name, "cgipat" ) == 0 )
		{
		value_required( name, value );
		cgi_pattern = e_strdup( value );
		}
	    else if ( strcasecmp( name, "cgilimit" ) == 0 )
		{
		value_required( name, value );
		cgi_limit = atoi( value );
		}
	    else if ( strcasecmp( name, "urlpat" ) == 0 )
		{
		value_required( name, value );
		url_pattern = e_strdup( value );
		}
	    else if ( strcasecmp( name, "noemptyreferers" ) == 0 ||
	              strcasecmp( name, "noemptyreferrers" ) == 0 )
		{
		no_value_required( name, value );
		no_empty_referrers = 1;
		}
	    else if ( strcasecmp( name, "localpat" ) == 0 )
		{
		value_required( name, value );
		local_pattern = e_strdup( value );
		}
	    else if ( strcasecmp( name, "throttles" ) == 0 )
		{
		value_required( name, value );
		throttlefile = e_strdup( value );
		}
	    else if ( strcasecmp( name, "host" ) == 0 )
		{
		value_required( name, value );
		hostname = e_strdup( value );
		}
	    else if ( strcasecmp( name, "logfile" ) == 0 )
		{
		value_required( name, value );
		logfile = e_strdup( value );
		}
	    else if ( strcasecmp( name, "vhost" ) == 0 )
		{
		no_value_required( name, value );
		do_vhost = 1;
		}
	    else if ( strcasecmp( name, "novhost" ) == 0 )
		{
		no_value_required( name, value );
		do_vhost = 0;
		}
	    else if ( strcasecmp( name, "globalpasswd" ) == 0 )
		{
		no_value_required( name, value );
		do_global_passwd = 1;
		}
	    else if ( strcasecmp( name, "noglobalpasswd" ) == 0 )
		{
		no_value_required( name, value );
		do_global_passwd = 0;
		}
	    else if ( strcasecmp( name, "pidfile" ) == 0 )
		{
		value_required( name, value );
		pidfile = e_strdup( value );
		}
	    else if ( strcasecmp( name, "charset" ) == 0 )
		{
		value_required( name, value );
		charset = e_strdup( value );
		}
	    else if ( strcasecmp( name, "p3p" ) == 0 )
		{
		value_required( name, value );
		p3p = e_strdup( value );
		}
	    else if ( strcasecmp( name, "max_age" ) == 0 )
		{
		value_required( name, value );
		max_age = atoi( value );
		}
	    else
		{
		(void) fprintf(
		    stderr, "%s: unknown config option '%s'\n", argv0, name );
		exit( 1 );
		}

	    /* Advance to next word. */
	    cp = cp2;
	    cp += strspn( cp, " \t\n\r" );
	    }
	}

    (void) fclose( fp );
    }


static void
value_required( char* name, char* value )
    {
    if ( value == (char*) 0 )
	{
	(void) fprintf(
	    stderr, "%s: value required for %s option\n", argv0, name );
	exit( 1 );
	}
    }


static void
no_value_required( char* name, char* value )
    {
    if ( value != (char*) 0 )
	{
	(void) fprintf(
	    stderr, "%s: no value required for %s option\n",
	    argv0, name );
	exit( 1 );
	}
    }


static char*
e_strdup( char* oldstr )
    {
    char* newstr;

    newstr = strdup( oldstr );
    if ( newstr == (char*) 0 )
	{
	syslog( LOG_CRIT, "out of memory copying a string" );
	(void) fprintf( stderr, "%s: out of memory copying a string\n", argv0 );
	exit( 1 );
	}
    return newstr;
    }


//iam's cruft below
static void dump_config(FILE* ptr){
  fprintf(ptr, "debug is %s\n", debug ? "true" : "false");
  fprintf(ptr, "port is %hu\n", port);
  fprintf(ptr, "dir is %s\n", dir);
  fprintf(ptr, "chroot is %s\n", do_chroot ? "true" : "false");
  fprintf(ptr, "data_dir is %s\n", data_dir);
  fprintf(ptr, "symlinkcheck is %s\n", no_symlink_check ? "false" : "true");
  fprintf(ptr, "user is %s\n", user);
  fprintf(ptr, "cgipat is %s\n", cgi_pattern);
  fprintf(ptr, "cgilimit is %d\n", cgi_limit);
  fprintf(ptr, "urlpat is %s\n", url_pattern);
  fprintf(ptr, "noemptyreferers is %s\n", no_empty_referrers ? "false" : "true");
  fprintf(ptr, "localpat is %s\n", local_pattern);
  fprintf(ptr, "throttles is %s\n", throttlefile);
  fprintf(ptr, "host is %s\n", hostname);
  fprintf(ptr, "logfile is %s\n", logfile);
  fprintf(ptr, "vhost is %s\n", do_vhost ? "true" : "false");
  fprintf(ptr, "globalpasswd is %s\n", do_global_passwd ? "true" : "false");
  fprintf(ptr, "pidfile is %s\n", pidfile);
  fprintf(ptr, "charset is %s\n", charset);
  fprintf(ptr, "p3p is %s\n", p3p);



}
