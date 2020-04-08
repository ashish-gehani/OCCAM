all: wc

wc: wc.c 
	${CC} -Wall -Xclang -disable-O0-optnone wc.c -o wc 


clean:
	rm -f .*.bc *.bc .*.o *.manifest wc wc_slash
	rm -rf slash
