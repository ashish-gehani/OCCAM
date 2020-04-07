# 'lighttpd' was built using the script 'https://github.com/SRI-CSL/OCCAM/blob/master/examples/linux/lighttpd/build.sh'
# The above script creates the files in the current directory which are used in the command below (except for the '/tmp/lighttpd.conf')

./install/sbin/lighttpd -m ./install/lib -D -f /tmp/lighttpd.conf
