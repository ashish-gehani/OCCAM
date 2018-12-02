    
    # bitcode build
    cd $HOME/Repositories/kernel-specialization/kernel-to-bitcode && \

    # for doing quick experiments we will comment "make defconfig" and uncomment the 
    # minimal configuration in the build script
    perl -pi -e 's/make defconfig/ # make defconfig/g' example-build.sh && \
    perl -pi -e 's/#cp/cp/g' example-build.sh && \


    # commenting automatic installation
    perl -pi -e 's/bash install.sh/#bash install.sh/g' example-build.sh && \

    ./example-build.sh

    echo "success : bitcode built"

    # thttpd bitcode generation and extracting the list of relevant system calls
    cd $HOME/Repositories/kernel-specialization/examples/thttpd
    cp $HOME/Repositories/musllvm/lib/crt1.o .
    cp $HOME/Repositories/musllvm/lib/libc.a .
    cp $HOME/Repositories/musllvm/lib/libc.a.bc .
    ./generate_specialized_syscall_list.sh specialize_libc.manifest syscallIds symbol_list
        
    echo "success : symbol_list produced"

    # slashing kernel with OCCAM while using "symbol_list" as the exclusion list
    cd $HOME/Repositories/kernel-specialization/kernel-slashing
    cp $HOME/Repositories/kernel-specialization/examples/thttpd/symbol_list .
    ./slash_kernel.sh $HOME/Repositories/kernel-specialization/kernel-to-bitcode/bitcode-build symbol_list
