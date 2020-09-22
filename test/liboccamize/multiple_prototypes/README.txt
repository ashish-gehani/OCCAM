Generalizing entry point specialization to include cpp programs which support multiple prototypes of a given function.

The clang frontend mangles these prototypes with the names and their types to differentiate between them. Fortunately, llvm
provides a demangle function which on mangled functions returns the demangled version (with type info).

In this case, the source code has two functions with the name add, however their mangled names vary. First we construct a
map of demangled function names to their mangled versions and then we create dynamic calls to those functions.

Both versions of add are kept in the specialized bitcode.
