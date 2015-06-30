#!/bin/bash

for x in *.bc_pic.a
do
    mv $x ${x%%.bc_pic.a}_pic.bc.a
done

for x in *.bc.a
do 
    echo cleaning... $x
    rm -rf $x.dir
    mkdir -p $x.dir
    cp $x $x.dir
    cd $x.dir

    N=`ar t $x`
    V=${N#\#_LLVM_SYM_TAB_}

    for y in $V
    do 
    	mkdir -p `dirname $y`
    done

    ar x $x
    
    for y in $V
    do
	${LLVM_HOME}/bin/opt -load=${OCCAM_HOME}/lib/libprevirt.so -Pfix-1function $y -o $y
    done

    rm $x
    ar rc $x $V
    
    mv $x ..
    cd ..
    rm -rf $x.dir

done
