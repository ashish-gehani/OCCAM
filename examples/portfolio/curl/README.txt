Needed to do the install to find out where the curl binary was.

Used 'get-bc -m curl' to produce this manifest:

curlgit/src/.curl-slist_wc.o.bc
curlgit/src/.curl-tool_binmode.o.bc
curlgit/src/.curl-tool_bname.o.bc
curlgit/src/.curl-tool_cb_dbg.o.bc
curlgit/src/.curl-tool_cb_hdr.o.bc
curlgit/src/.curl-tool_cb_prg.o.bc
curlgit/src/.curl-tool_cb_rea.o.bc
curlgit/src/.curl-tool_cb_see.o.bc
curlgit/src/.curl-tool_cb_wrt.o.bc
curlgit/src/.curl-tool_cfgable.o.bc
curlgit/src/.curl-tool_convert.o.bc
curlgit/src/.curl-tool_dirhie.o.bc
curlgit/src/.curl-tool_doswin.o.bc
curlgit/src/.curl-tool_easysrc.o.bc
curlgit/src/.curl-tool_formparse.o.bc
curlgit/src/.curl-tool_getparam.o.bc
curlgit/src/.curl-tool_getpass.o.bc
curlgit/src/.curl-tool_help.o.bc
curlgit/src/.curl-tool_helpers.o.bc
curlgit/src/.curl-tool_homedir.o.bc
curlgit/src/.curl-tool_hugehelp.o.bc
curlgit/src/.curl-tool_libinfo.o.bc
curlgit/src/.curl-tool_main.o.bc
curlgit/src/.curl-tool_metalink.o.bc
curlgit/src/.curl-tool_msgs.o.bc
curlgit/src/.curl-tool_operate.o.bc
curlgit/src/.curl-tool_operhlp.o.bc
curlgit/src/.curl-tool_panykey.o.bc
curlgit/src/.curl-tool_paramhlp.o.bc
curlgit/src/.curl-tool_parsecfg.o.bc
curlgit/src/.curl-tool_strdup.o.bc
curlgit/src/.curl-tool_setopt.o.bc
curlgit/src/.curl-tool_sleep.o.bc
curlgit/src/.curl-tool_urlglob.o.bc
curlgit/src/.curl-tool_util.o.bc
curlgit/src/.curl-tool_vms.o.bc
curlgit/src/.curl-tool_writeout.o.bc
curlgit/src/.curl-tool_xattr.o.bc
curlgit/lib/.curl-strtoofft.o.bc
curlgit/lib/.curl-nonblock.o.bc
curlgit/lib/.curl-warnless.o.bc

otool -L install/bin/curl:

install/bin/curl:
	/Users/iam/Repositories/GitHub/OCCAM/examples/portfolio/curl/install/lib/libcurl.4.dylib (compatibility version 10.0.0, current version 10.0.0)
	/usr/local/opt/libidn2/lib/libidn2.0.dylib (compatibility version 4.0.0, current version 4.3.0)
	/System/Library/Frameworks/LDAP.framework/Versions/A/LDAP (compatibility version 1.0.0, current version 2.4.0)
	/usr/local/lib/libz.1.dylib (compatibility version 1.0.0, current version 1.2.8)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.0.0)



not a static build:

  -rw-r--r--   1 iam  staff  469056 Jan 22 17:20 curl.bc


llvm-link  -only-needed curl.bc libcurl.so.4.5.0.bc -o amalgamation.bc
