#start with occam make
#then make llvm
#then make llvm2

all:
	gcc -v --sysroot=/opt/occam/root hello.c -c 
	gcc -v --sysroot=/opt/occam/root hello.o -o hello -static 

#
# can't pass --native to llvm-ld because it doesn't understand --sysroot so we split it up and
# let gcc do the final part. To figure out what to do:
# use llvm-ld --native -v ... 
#
llvm:
	llvm-ld hello_main.bc -o hello_main_step_1
	llc hello_main_step_1.bc -x86-asm-syntax=att -o  hello_main_step_2.s
	gcc -v --sysroot=/opt/occam/root -fno-strict-aliasing -O3 -c -o hello_main_step_3.o hello_main_step_2.s 
#	gcc -v --sysroot=/opt/occam/root -fno-strict-aliasing -O3 -o hello_main_step_3 hello_main_step_2.s  -static 
# now do make llvm2

llvm2:
	ld --sysroot=/opt/occam/root -m elf_x86_64 -static -o hello_main_step_4 /opt/occam/root/usr/lib/crt1.o /opt/occam/root/usr/lib/crti.o   -L/opt/occam/root/usr/lib  hello_main_step_3.o  /opt/occam/root/usr/lib/crtn.o -lc


#
# SUPERIOR, ALTERNATIVE TECHNIQUE: For the last step,
# pass the right options to ld with llvm-ld's -Xlinker argument
#
better:
	llvm-ld -native -Xlinker=--sysroot=/opt/occam/root -Xlinker=-static \
          hello_main.bc -o hello_direct


clean:
	rm -f *.o *.bc *.ll *.s hello hello_main.bc.manifest hello_main_step_* hello_direct


