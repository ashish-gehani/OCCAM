#change these to something suitable if you are not running in a vagrant box.
USER=vagrant
INSTALL=/vagrant

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

build: ${PCRE}_build ${APR}_build ${APR_UTIL}_build ${HTTPD}_build

${PCRE}.tar.gz:
	wget ${PCRE_URL}

${PCRE}.tar: ${PCRE}.tar.gz
	gunzip -k ${PCRE}.tar.gz

${PCRE}: ${PCRE}.tar
	tar xvf ${PCRE}.tar

${PCRE}_build: ${PCRE}
	mkdir -p pcre_build                                         && \
	cd pcre_build                                               && \
	CC=wllvm ../${PCRE}/configure --prefix=${INSTALL}/${PCRE}   && \
	CC=wllvm make 	                                            && \
	cd  .libs                                                   && \
	extract-bc libpcre.so                                       && \
	cp libpcre.so.bc ../../                                     && \
	cd  ..                                                      && \
	make install                                                   


${APR}.tar.gz:
	wget ${APR_URL}

${APR}.tar: ${APR}.tar.gz
	gunzip -k ${APR}.tar.gz

${APR}: ${APR}.tar
	tar xvf ${APR}.tar

${APR}_build: ${APR}
	mkdir -p apr_build                                       && \
	cd apr_build                                             && \
	CC=wllvm ../${APR}/configure --prefix=${INSTALL}/${APR}  && \
	CC=wllvm make                                            && \
	cd .libs                                                 && \
	extract-bc libapr-1.so                                   && \
	cp libapr-1.so.bc ../../                                 && \
	cd ..                                                    && \
	make install                                                

${APR_UTIL}.tar.gz:
	wget ${APR_UTIL_URL}

${APR_UTIL}.tar: ${APR_UTIL}.tar.gz
	gunzip -k ${APR_UTIL}.tar.gz

${APR_UTIL}: ${APR_UTIL}.tar
	tar xvf ${APR_UTIL}.tar

${APR_UTIL}_build: ${APR_UTIL}
	mkdir -p apr_util_build                                            && \
	cd apr_util_build                                                  && \
	CC=wllvm ../${APR_UTIL}/configure --prefix=${INSTALL}/${APR_UTIL}     \
                                          --with-apr=${INSTALL}/${APR}     && \
	CC=wllvm make                                                      && \
	cd .libs                                                           && \
	extract-bc libaprutil-1.so                                         && \
	cp libaprutil-1.so.bc ../../                                       && \
	cd ..                                                              && \
	make install                                                          


${HTTPD}.tar.gz:
	wget ${HTTPD_URL}

${HTTPD}.tar: ${HTTPD}.tar.gz
	gunzip -k ${HTTPD}.tar.gz

${HTTPD}: ${HTTPD}.tar
	tar xvf ${HTTPD}.tar

${HTTPD}_build: ${HTTPD}
	mkdir -p httpd_build                                                          && \
	cd  httpd_build                                                               && \
	CC=wllvm ../${HTTPD}/configure --prefix=${INSTALL}/${HTTPD}                      \
                                       --with-pcre=${INSTALL}/${PCRE}/bin/pcre-config    \
                                       --with-apr=${INSTALL}/${APR}                      \
				       --with-apr-util=${INSTALL}/${APR_UTIL}         && \
	CC=wllvm make                                                                 && \
	extract-bc httpd                                                              && \
	cp httpd.bc ../                                                               && \
	make install                                                                     


clean:
	rm -rf *~  *_build  previrt httpd


very_clean: clean
	rm -rf ${HTTPD} ${APR_UTIL} ${APR} ${PCRE}

spotless: very_clean
	rm -f *.tar.gz *.tar

check_sanity:
ifneq ($(shell whoami),${USER})
	$(error you are not running in a vagrant box, make sure the install directories make sense)
endif
