Automatic library specialization mode:

Uses a modified manifiest file with a new key 'lib_spec'. The user would
specify the main module as normal, but any library modules would be added into the
lib_spec key. This would run OCCAM in library specialization mode where it would produce
the specialized binary and the specialized library bitcode as well.

Setting akin to that in 'Nibbler: Debloating Binary Shared Libraries'. Here sets of library
bitcodes can be specialized according to sets of main program bitcodes. The libraries would hence
be specialized according to the union of the requirements of all the main bitcodes which
use them.
