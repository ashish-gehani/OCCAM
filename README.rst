|PyPI version| |Build Status|

Prerequisites
=============

`OCCAM <https://github.com/SRI-CSL/OCCAM>`__ currently works fine on
Linux, OS X, and FreeBSD. You will need an installation of llvm-3.5. If
you need to generate application bitcode, you will want to install
wllvm, either from the the pip
`package <https://pypi.python.org/pypi/wllvm/>`__ or the GitHub
`repository <https://github.com/SRI-CSL/whole-program-llvm.git>`__.

Building and Installing
=======================

Set where OCCAM's library will be stored:

::

      export OCCAM_HOME={path to location in your home directory}

Point to your LLVM's location, if non-standard:

::

      export LLVM_HOME=/usr/local/llvm-3.5
      export LLVM_CONFIG=llvm-config-3.5

Set where system libraries, including Google Protocol Buffers, are
located:

::

      export LD_FLAGS='-L/usr/local/lib'

Build and install OCCAM with:

::

      make
      make install

Using OCCAM
===========

You can choose to record logs from the OCCAM tool by setting the
following variables:

::

      export OCCAM_LOGFILE={absolute path to log location}
      export OCCAM_LOGLEVEL={INFO, WARNING, or ERROR}

Using razor
===========

``razor`` is a pip package that relies on the same dynamic library as
``occam``, so you should first build and install ``occam`` as described
above. You can install it from this repository, or you can just do a

::

    pip install razor

To install and editable version from this repository:

::

    make -f Makefile develop

This may require sudo priviliges. Either way you can now use slash:

::

    slash [--work-dir=<dir>]  [--force] [--no-strip] [--intra-spec-policy=<type>] [--inter-spec-policy=<type>] <manifest>

where

::

    type=none|aggressive|nonrec-aggressive

The value ``none`` will prevent any inter or intra-module
specialization. The value ``aggressive`` specializes a call if any
parameter is a constant. The value ``nonrec-aggressive`` specializes a
call if the function is non-recursive and any parameter is a constant.


The Manifest(o)
===============

The manifest for ``slash`` should be valid JSON. The following keys have
meaning:

-  ``main`` : a path to the bitcode module containing the ``main`` entry
   point.

-  ``modules``: a list of paths to the other bitcode modules needed.

-  ``binary`` : the name of the desired executable.

-  ``native_libs`` : a list of flags (``-lm``, ``-lc``, ``-lpthread``)
   or paths to native objects (``.o``, ``.a``, ``.so``, ``.dylib``)

-  ``ldflags``: a list of linker flags such as ``--static``,
   ``--nostdlib``

-  ``args`` : the list of arguments you wish to specialize in the main
   of ``main``.

As an example, (see ``examples/linux/apache``), to previrtualize apache:

::

    { "main" : "httpd.bc"
    , "binary"  : "httpd_slashed"
    , "modules"    : ["libapr-1.so.bc", "libaprutil-1.so.bc", "libpcre.so.bc"]
    , "native_libs" : ["-lcrypt", "-ldl", "-lpthread"]
    , "args"    : ["-d", "/var/www"]
    , "name"    : "httpd"
    }

Another example, (see ``examples/linux/musl_nweb``), specializes
``nweb`` with ``musl libc.c``:

::

    { "main" :  "nweb.o.bc"
    , "binary"  : "nweb_razor"
    , "modules"    : ["libc.a.bc"]
    , "native_libs" : ["crt1.o", "libc.a"]
    , "ldflags" : ["-static", "-nostdlib"]
    , "args"    : ["8181", "./root"]
    , "name"    : "nweb"
    }

.. |PyPI version| image:: https://badge.fury.io/py/razor.svg
   :target: https://badge.fury.io/py/razor
.. |Build Status| image:: https://travis-ci.org/SRI-CSL/OCCAM.svg?branch=master
   :target: https://travis-ci.org/SRI-CSL/OCCAM
