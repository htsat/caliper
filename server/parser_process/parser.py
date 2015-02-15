## wuyanjun 00291783
## wu.wu@hisilicon.com
## Copyright

#!/usr/bin/python

import os
import sys
import logging
import pdb

import test_perf_tranver as traverse
import caliper.server.utils as server_utils

LOCATION = os.path.dirname(sys.modules[__name__].__file__)
CALIPER_DIR = os.path.join(LOCATION, '..', '..')
OUT_DIR = os.path.join(CALIPER_DIR, 'gen', 'output')#"output/parser_yaml_result.py"

def traverse_caliper_output(hosts):

    YAML_DIR = os.path.join(OUT_DIR, 'yaml')
   
    host_name = server_utils.get_host_name(hosts)
    host_yaml_name = host_name + '_score.yaml'
    host_yaml_file = os.path.join(YAML_DIR, host_yaml_name)
    try:
        return_code = traverse.traverser_perf(hosts, host_yaml_file)
    except Exception, e:
        logging.info(e.args[0], e.args[1])
        raise
    else:
        if return_code != 1:
            logging.info("there is wrong when dealing the yaml file")
    
def parser_caliper(host):
    try:
        traverse_caliper_output(host)
    except Exception, e:
        logging.info(e.args[0], e.args[1])
