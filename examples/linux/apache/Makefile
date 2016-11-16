USER=$(shell whoami)
INSTALL=${PWD}/apache-install


#current versions as of 11/2016
PCRE=pcre-8.39
APR=apr-1.5.2
APR_UTIL=apr-util-1.5.4
HTTPD=httpd-2.4.23

#the urls (if the versions change you should check these)
PCRE_URL=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${PCRE}.tar.gz
APR_URL=http://download.nextag.com/apache/apr/${APR}.tar.gz
APR_UTIL_URL=http://shinyfeather.com/apr/${APR_UTIL}.tar.gz
HTTPD_URL=http://apache.cs.utah.edu/httpd/${HTTPD}.tar.gz


all: build

build: ${PCRE}_build ${APR}_build ${APR_UTIL}_build ${HTTPD}_build

${PCRE}.tar.gz:
	wget ${PCRE_URL}

${PCRE}.tar: ${PCRE}.tar.gz
	gunzip -k ${PCRE}.tar.gz

${PCRE}: ${PCRE}.tar
	tar xvf ${PCRE}.tar

${PCRE}_build: ${PCRE}
	mkdir -p ${PCRE}_build                                      && \
	cd ${PCRE}_build                                            && \
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
	mkdir -p ${APR}_build                                    && \
	cd ${APR}_build                                          && \
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
	mkdir -p ${APR_UTIL}_build                                         && \
	cd ${APR_UTIL}_build                                               && \
	CC=wllvm ../${APR_UTIL}/configure --prefix=${INSTALL}/${APR_UTIL}     \
                                          --with-apr=${INSTALL}/${APR}     && \
	CC=wllvm make                                                      && \
	cd .libs                                                           && \
	extract-bc libaprutil-1.so                                         && \
	cp libaprutil-1.so.bc ../../                                       && \
	cd ..                                                              && \
	make install                                                          

#	cd xml/expat/.libs                                                 && \
#	extract-bc libexpat.so                                             && \
#	mv libexpat.so.bc ../../../../                                     && \
#	cd ../../..                                                        && \


${HTTPD}.tar.gz:
	wget ${HTTPD_URL}

${HTTPD}.tar: ${HTTPD}.tar.gz
	gunzip -k ${HTTPD}.tar.gz

${HTTPD}: ${HTTPD}.tar
	tar xvf ${HTTPD}.tar

${HTTPD}_build: ${HTTPD}
	mkdir -p ${HTTPD}_build                                                       && \
	cd  ${HTTPD}_build                                                            && \
	CC=wllvm ../${HTTPD}/configure --prefix=${INSTALL}/${HTTPD}                      \
                                       --with-pcre=${INSTALL}/${PCRE}/bin/pcre-config    \
                                       --with-apr=${INSTALL}/${APR}                      \
				       --with-apr-util=${INSTALL}/${APR_UTIL}         && \
	CC=wllvm make                                                                 && \
	extract-bc httpd                                                              && \
	cp httpd.bc ../                                                               && \
	make install                                                                     


clean:
	rm -rf *~  *_build  slash linked_slash httpd *.manifest


very_clean: clean
	rm -rf ${HTTPD} ${APR_UTIL} ${APR} ${PCRE}

spotless: very_clean
	rm -f *.tar.gz *.tar *.bc

