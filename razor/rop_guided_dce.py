import sys
import tempfile
import shutil
from . import driver
from . import stringbuffer
from . import utils

# TODO: split the code between running seahorn and transformation that
# replaces assert(0) with unreachable

# Try to prove that fname is unreachable with a timeout and a memory limit.
# The flag is_loop_free indicates whether bounded model
# checking can be used.
def seahorn(sea_cmd, input_file, fname, is_loop_free, cpu, mem, opt_options):
    """ running SeaHorn (https://github.com/seahorn/seahorn)
    """

    def check_status(output_str):
        if "unsat" in output_str:
            return True
        if "sat" in output_str:
            return False
        return None

    # 1. Instrument the program with assertions
    sea_infile = tempfile.NamedTemporaryFile(suffix='.bc', delete=False)
    sea_infile.close()
    args = ['--Padd-verifier-calls',
            '--Padd-verifier-call-in-function={0}'.format(fname)]
    driver.previrt(input_file, sea_infile.name, args)

    # 2. Run SeaHorn
    sea_args = [  '--strip-extern'
                , '--enable-indvar'
                , '--enable-loop-idiom'
                , '--symbolize-constant-loop-bounds'
                , '--unfold-loops-for-dsa'
                , '--simplify-pointer-loops'
                , '--horn-sea-dsa-local-mod'
                , '--horn-sea-dsa-split'
                , '--dsa=sea-cs'
                , '--cpu={0}'.format(cpu)
                , '--mem={0}'.format(mem)]

    if is_loop_free:
        # the bound shouldn't affect for proving unreachability of the
        # function but we need a global bound for all loops.
        sea_args = ['bpf', '--bmc=mono', '--bound=3'] + \
                   sea_args + \
                   [   '--horn-bv-global-constraints=true'
                     , '--horn-bv-singleton-aliases=true'
                     , '--horn-bv-ignore-calloc=false'
                     , '--horn-at-most-one-predecessor']
        sys.stderr.write('Running SeaHorn with BMC engine on {0} ...\n'.format(fname))
    else:
        sea_args = ['pf'] + \
                   sea_args + \
                   [   '--horn-global-constraints=true'
                     , '--horn-singleton-aliases=true'
                     , '--horn-ignore-calloc=false'
                     #, '--crab', '--crab-dom=int'
                   ]
        sys.stderr.write('Running SeaHorn with Spacer+AI engine on {0} ...\n'.format(fname))
    sea_args = sea_args + [sea_infile.name]

    sb = stringbuffer.StringBuffer()
    retcode= driver.run(sea_cmd, sea_args, sb, False)
    status = check_status(str(sb))
    if retcode == 0 and status:
        # 3. If SeaHorn proved unreachability of the function then we
        #    add assume(false) at the entry of that function.
        sys.stderr.write('\tSeaHorn proved unreachability of {0}!\n'.format(fname))
        sea_outfile = tempfile.NamedTemporaryFile(suffix='.bc', delete=False)
        sea_outfile.close()
        args = ['--Preplace-verifier-calls-with-unreachable']
        driver.previrt_progress(sea_infile.name, sea_outfile.name, args)
        # 4. And, we run the optimized to remove that function
        #sea_opt_outfile = tempfile.NamedTemporaryFile(suffix='.bc', delete=False)
        #sea_opt_outfile.close()
        #optimize(sea_outfile.name, sea_opt_outfile.name, True, opt_options)
        #return sea_opt_outfile.name
        return sea_outfile
    sys.stderr.write('\tSeaHorn could not prove unreachability of {0}:\n'.format(fname))
    if retcode != 0:
        sys.stderr.write('\t\tpossible timeout or memory limits reached\n')
    elif not status:
        sys.stderr.write('\t\tSeaHorn got a counterexample\n')
    return input_file

def rop_guided_dce(input_file,
           # entry functions
           entries,
           # file with ROP gadgets
           ropfile,
           output_file,
           ## number of ROP gadgets
           benefit_threshold,
           ## number of loops
           cost_threshold,
           ## SeaHorn timeout in seconds
           timeout,
           ## SeaHorn memory limit in MB
           memlimit,
           ## Options for opt
           opt_options):
    """ use SeaHorn model-checker to remove dead functions
    """
    sea_cmd = utils.get_seahorn()
    if sea_cmd is None:
        sys.stderr.write('SeaHorn not found: skipped model-checking-based dce.')
        shutil.copy(input_file, output_file)
        return False

    cost_benefit_out = tempfile.NamedTemporaryFile(delete=False)
    args  = ['--Pcost-benefit-cg']
    args += ['--Pbenefits-filename={0}'.format(ropfile)]
    args += ['--Pcost-benefit-output={0}'.format(cost_benefit_out.name)]
    for e in entries:
        args += ['--Pcallgraph-roots={0}'.format(e)]

    driver.previrt(input_file, '/dev/null', args)
    seahorn_queries = []
    for line in cost_benefit_out:
        tokens = line.split()
        # Expected format of each token: FUNCTION BENEFIT COST
        # where FUNCTION is a string, BENEFIT is an integer, and COST is an integer
        if len(tokens) < 3:
            sys.stderr.write('ERROR: unexpected format of {0}\n'.format(cost_benefit_out.name))
            return False
        fname = tokens[0]
        fbenefit= int(tokens[1])
        fcost = int(tokens[2])
        if fbenefit >= benefit_threshold and fcost <= cost_threshold:
            seahorn_queries.extend([(fname, fcost == 0)])
    cost_benefit_out.close()

    if seahorn_queries == []:
        print("No queries for SeaHorn ...")

    change = False
    curfile = input_file
    for (fname, is_loop_free) in seahorn_queries:
        if fname == 'main' or \
           fname.startswith('devirt') or \
           fname.startswith('seahorn'):
            continue
        nextfile = seahorn(sea_cmd, curfile, \
                           fname, \
                           is_loop_free, \
                           timeout, memlimit, \
                           opt_options)
        change = change | (curfile != nextfile)
        curfile = nextfile
    shutil.copy(curfile, output_file)
    return change
