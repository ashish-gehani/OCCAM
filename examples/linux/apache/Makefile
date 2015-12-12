

all: src

src: apr apr_util httpd pcre

pcre: 
	wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.gz
	tar xvfz pcre-8.38.tar.gz

pcre_build:
	mkdir pcre_build; cd pcre_build; CC=wllvm ../pcre-8.38/configure --prefix=/vagrant/pcre; CC=wllvm make
	cd  pcre_build/.libs; extract-bc libpcre.so; cp libpcre.so ../../
	cd  pcre_build; make install


apr:
	wget http://download.nextag.com/apache/apr/apr-1.5.2.tar.gz
	tar xvfz apr-1.5.2.tar.gz

apr_build:
	mkdir apr_build; cd apr_build; CC=wllvm ../apr-1.5.2/configure --prefix=/vagrant/apr; CC=wllvm make
	cd  apr_build/.libs; extract-bc libapr-1.so; cp libapr-1.so.bc ../../
	cd  apr_build; make install

apr_util:
	wget http://shinyfeather.com//apr/apr-util-1.5.4.tar.gz
	tar xvfz apr-util-1.5.4.tar.gz

apr_util_build:
	mkdir apr_util_build; cd apr_util_build; CC=wllvm ../apr-util-1.5.4/configure --prefix=/vagrant/apr_util --with-apr=/vagrant/apr; CC=wllvm make
	cd  apr_util_build/.libs; extract-bc libaprutil-1.so; cp libaprutil-1.so.bc ../../

httpd:
	wget http://apache.claz.org/httpd/httpd-2.4.17.tar.gz
	tar xvfz httpd-2.4.17.tar.gz

httpd_build:
	mkdir httpd_build; cd  httpd_build; CC=wllvm ../httpd-2.4.17/configure --prefix=/vagrant/httpd --with-pcre=/vagrant/pcre/bin/pcre-config --with-apr=/vagrant/apr --with-apr-util=/vagrant/apr_util
	cd httpd_build; CC=wllvm make; extract-bc httpd; cp httpd.bc ../

clean:
	rm -rf *~ *.gz *_build 

very_clean: clean
	rm -rf httpd-2.4.17 apr-util-1.5.4 apr-1.5.2 pcre-8.38
