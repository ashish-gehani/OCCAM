# Install SPEC 2006 benchmarks #

We assume, of course, that SPEC 2006 benchmarks have been downloaded
somehow. Let us call `SPEC_CPU2006` the directory name where the
benchmarks are located.

Read `README.txt` before installing SPEC benchmarks. This is just a
quick guide in case everything works smoothly.

1. `cd SPEC_CPU2006`

2. `./install.sh`
   This script will ask for an installation directory `<INSTALL_DIR>`.

3. `cd <INSTALL_DIR> && . shrc` 
   This will set `SPEC` and `SPECSPECPERLLIB` environment variables.

# Preparation for specialization of SPEC 2006 benchmarks #

4. Modify `occam_home` in `macosx-gclang500.cfg` accordingly.
   *FIXME*: we would like to use environment variable `OCCAM_HOME`
   instead, so that we can skip this step.

5. `cp macosx-gclang500.cfg ${SPEC}/config`
   *FIXME*: `runspec` seems to need all the config files to be in the
   `config` directory.  It would be great to have config files in
   arbitrary locations so that we can skip this step.

If you are on a Linux machine, use `linux64-amd64-gclang500.cfg` as
the configuration file.

# Specialize SPEC 2006 benchmarks #

Go to the corresponding benchmark directory (e.g., `cint2006/bzip2`) and
perform the following steps:

6. Type `make`
7. Type `build.sh`


# About SPEC 2006 benchmarks #

- `cint2006` directory: benchmarks for C + INT  
  - `bzip2`
  - `gcc`
  - `gobmk`
  - `h264ref`
  - `hmmer`
  - `libquantum`
  - `mcf`
  - `perlbench`
  - `sjeng`
  - `specrand`
  
- `cfp2006` directory: benchmarks for C + FP
  - `lbm`
  - `milc`
  - `sphinx3`

# TODO #

Currently, we do not provide `constraints` or `args` fields in the
manifest.
