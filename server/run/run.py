## wuyanjun 00291783
## wu.wu@hisilicon.com
## Copyright

#!/usr/bin/python
import os
import sys
import shutil
import logging
import pdb

try:
    import caliper.common as common
except ImportError:
    import common

from caliper.server.run import test_run
from caliper.client.shared import error
from caliper.server import utils as server_utils

def run_all_tests(caliper_dir, gen_dir, target):
    try:
        server_arch = server_utils.get_local_machine_arch()
    except error.ServUnsupportedError, e:
        raise error.ServRunError(e.args[0], e.args[1])
    except error.ServRunError, e:
        raise error.ServRunError(e.args[0], e.args[1])
    server_execution_dir = os.path.abspath(os.path.join(gen_dir, server_arch))
   
    gen_dir = os.path.join( server_execution_dir, '..' )
    DES_DIR = os.path.abspath(os.path.join(gen_dir, "output"))
    SOURCE_DIR = os.path.join(caliper_dir,"server/parser_process/show_output/output")
   
    if os.path.exists(DES_DIR):
        shutil.rmtree(DES_DIR)
    shutil.copytree(SOURCE_DIR, DES_DIR, symlinks=False, ignore=None)

    try:
        logging.debug("beginnig to run the test cases")
        test_run.caliper_run(caliper_dir, server_execution_dir, target)
    except error.CmdError, e:
        print "There is wrong in running benchmarks"

if __name__=="__main__":
    if (len(sys.argv) >= 4):
        run_all_tests(sys.argv[1], sys.argv[2], sys.argv[3])
