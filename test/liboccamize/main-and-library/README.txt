Automatic library specialization mode:

Uses a modified manifiest file with a new key 'lib_spec'. The user would
specify the main module as normal, but any library modules would be added into the
lib_spec key. This would run OCCAM in library specialization mode where it would produce
the specialized binary and the specialized library bitcode as well.
