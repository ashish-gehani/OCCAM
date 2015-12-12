#current versions as of 12/2015
PCRE=pcre-8.38
APR=apr-1.5.2
APR_UTIL=apr-util-1.5.4
HTTPD=httpd-2.4.17

PCRE_URL=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${PCRE}.tar.gz
APR_URL=http://download.nextag.com/apache/apr/${APR}.tar.gz
APR_UTIL_URL=http://shinyfeather.com/apr/${APR_UTIL}.tar.gz
HTTPD_URL=http://apache.claz.org/httpd/${HTTPD}.tar.gz


all: build

build: pcre_build apr_build apr_util_build httpd_build

pcre_src: 
	wget ${PCRE_URL}
	tar xvfz ${PCRE}.tar.gz

pcre_build: pcre_src
	mkdir -p pcre_build                                    && \
	cd pcre_build                                          && \
	CC=wllvm ../${PCRE}/configure --prefix=/vagrant/pcre   && \
	CC=wllvm make 	                                       && \
	cd  .libs                                              && \
	extract-bc libpcre.so                                  && \
	cp libpcre.so.bc ../../                                && \
	cd  ..                                                 && \
	make install


apr_src:
	wget ${APR_URL}
	tar xvfz ${APR}.tar.gz

apr_build: apr_src
	mkdir -p apr_build                                  && \
	cd apr_build                                        && \
	CC=wllvm ../${APR}/configure --prefix=/vagrant/apr  && \
	CC=wllvm make                                       && \
	cd .libs                                            && \
	extract-bc libapr-1.so                              && \
	cp libapr-1.so.bc ../../                            && \
	cd ..                                               && \
	make install

apr_util_src:
	wget ${APR_UTIL_URL}
	tar xvfz ${APR_UTIL}.tar.gz

apr_util_build: apr_util_src
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

httpd_src:
	wget ${HTTPD_URL}
	tar xvfz ${HTTPD}.tar.gz

httpd_build: httpd_src
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
