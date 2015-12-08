import os

ENV = {
    'clang'      :  'LLVM_CC_NAME',
    'clang++'    :  'LLVM_CXX_NAME',  
    'llvm-link'  :  'LLVM_LINK_NAME',    
    'llvm-ar'    :  'LLVM_AR_NAME',    
    'llvm-as'    :  'LLVM_AS_NAME',    
    'llvm-ld'    :  'LLVM_LD_NAME',    
    'llc'        :  'LLVM_LLC_NAME',    
    'opt'        :  'LLVM_OPT_NAME',    
    'llvm-nm'    :  'LLVM_NM_NAME',    
    'clang-cpp'  :  'LLVM_CPP_NAME',  
}


def env_version(name):
    env_name = None
    if name in env:
        env_name = os.getenv(env[name])
    return env_name if env_name else name



#export LLVM_CC_NAME=clang-3.5

#export LLVM_CXX_NAME=clang++-3.5

#export LLVM_LINK_NAME=llvm-link-3.5

#export LLVM_AR_NAME=llvm-ar-3.5

#export LLVM_AS_NAME=llvm-as-3.5

#export LLVM_LD_NAME=llvm-ld-3.5

#export LLVM_LLC_NAME=llc-3.5

#export LLVM_OPT_NAME=opt-3.5

#export LLVM_NM_NAME=llvm-nm-3.5

#export LLVM_CPP_NAME=clang-cpp-3.5




