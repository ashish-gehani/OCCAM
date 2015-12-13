#current versions as of 12/2015
PCRE=pcre-8.38
APR=apr-1.5.2
APR_UTIL=apr-util-1.5.4
HTTPD=httpd-2.4.17

#the urls (if the versions change you should check these)
PCRE_URL=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${PCRE}.tar.gz
APR_URL=http://download.nextag.com/apache/apr/${APR}.tar.gz
APR_UTIL_URL=http://shinyfeather.com/apr/${APR_UTIL}.tar.gz
HTTPD_URL=http://apache.claz.org/httpd/${HTTPD}.tar.gz


all: check_sanity build

build: pcre_build apr_build apr_util_build httpd_build

${PCRE}: 
	wget ${PCRE_URL}
	tar xvfz ${PCRE}.tar.gz

pcre_build: ${PCRE}
	mkdir -p pcre_build                                    && \
	cd pcre_build                                          && \
	CC=wllvm ../${PCRE}/configure --prefix=/vagrant/pcre   && \
	CC=wllvm make 	                                       && \
	cd  .libs                                              && \
	extract-bc libpcre.so                                  && \
	cp libpcre.so.bc ../../                                && \
	cd  ..                                                 && \
	make install


${APR}:
	wget ${APR_URL}
	tar xvfz ${APR}.tar.gz

apr_build: ${APR}
	mkdir -p apr_build                                  && \
	cd apr_build                                        && \
	CC=wllvm ../${APR}/configure --prefix=/vagrant/apr  && \
	CC=wllvm make                                       && \
	cd .libs                                            && \
	extract-bc libapr-1.so                              && \
	cp libapr-1.so.bc ../../                            && \
	cd ..                                               && \
	make install

${APR_UTIL}:
	wget ${APR_UTIL_URL}
	tar xvfz ${APR_UTIL}.tar.gz

apr_util_build: ${APR_UTIL}
	mkdir -p apr_util_build                                            && \
	cd apr_util_build                                                  && \
	CC=wllvm ../${APR_UTIL}/configure --prefix=/vagrant/apr_util          \
                                          --with-apr=/vagrant/apr          && \
	CC=wllvm make                                                      && \
	cd .libs                                                           && \
	extract-bc libaprutil-1.so                                         && \
	cp libaprutil-1.so.bc ../../                                       && \
	cd ..                                                              && \
	make install

${HTTPD}:
	wget ${HTTPD_URL}
	tar xvfz ${HTTPD}.tar.gz

httpd_build: ${HTTPD}
	mkdir -p httpd_build                                                     && \
	cd  httpd_build                                                          && \
	CC=wllvm ../${HTTPD}/configure --prefix=/vagrant/httpd                      \
                                       --with-pcre=/vagrant/pcre/bin/pcre-config    \
                                       --with-apr=/vagrant/apr                      \
				       --with-apr-util=/vagrant/apr_util         && \
	CC=wllvm make                                                            && \
	extract-bc httpd                                                         && \
	cp httpd.bc ../                                                          && \
	make install


clean:
	rm -rf *~ *.gz *_build  previrt httpd


very_clean: clean
	rm -rf ${HTTPD} ${APR_UTIL} ${APR} ${PCRE}


check_sanity:
ifneq ($(shell whoami),vagrant)
	$(error you are not running in a vagrant box the install directories will not make sense)
endif
