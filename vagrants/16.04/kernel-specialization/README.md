Start off by running the vagrant script:

```
vagrant up
```

The above script will generate a virtual machine with all the dependencies for kernel specialization built in. These include:
1) [gllvm](https://github.com/SRI-CSL/gllvm)
2) [OCCAM](https://github.com/SRI-CSL/OCCAM)
3) [musllvm](https://github.com/SRI-CSL/musllvm)

Once the virtual machine has been generated, you can login with the default credentials (username : vagrant, password : vagrant) and run the following commands:

```
cd $HOME/Repositories/OCCAM/vagrants/16.04/kernel-specialization/
./generate_kernel_specialized_for_thttpd.sh
```

The above will generate a version of the kernel with just enough system calls to support "thttpd" at the location:
```
$HOME/Repositories/kernel-specialization/kernel-to-bitcode/bitcode-build
```
In particular the script performs the following steps
1) Clones a suitable version of linux, builds it and generates the bitcode at the location
```
$HOME/Repositories/kernel-specialization/kernel-to-bitcode/bitcode-build
```
A step by step breakdown of this part can be found in the [corresponding Readme](https://github.com/SRI-CSL/kernel-specialization/blob/master/kernel-to-bitcode/README.md).

2) Clones the thttpd source, generates its bitcode, generates a musl-libc version specialized for thttpd and extracts the corresponding system calls at the location
```
$HOME/Repositories/kernel-specialization/example/thttpd
```
[Corresponding Readme](https://github.com/SRI-CSL/kernel-specialization/blob/master/examples/thttpd/README.md)

3) Generates a version of the kernel specialized for the set of system calls generated above. [Corresponding Readme](https://github.com/SRI-CSL/kernel-specialization/blob/master/kernel-slashing/README.md).
