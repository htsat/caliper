#!/usr/bin/python
## wuyanjun w00291783
## wu.wu@hisilicon.com
## Copyright

import os
import sys
#from datetime import datetime
import subprocess
import ConfigParser
import re
import stat
import shutil
import pdb
import logging

try:
    import caliper.common as common
except ImportError:
    import common

import caliper.server.utils as server_utils
from caliper.client.shared import error

CURRENT_PATH = os.path.dirname(sys.modules[__name__].__file__)
CALIPER_DIR = os.path.abspath(os.path.join(CURRENT_PATH, "..", ".."))
GEN_DIR = os.path.join(CALIPER_DIR, "gen")
TEST_CFG_DIR = os.path.join(CALIPER_DIR, "test_cases_cfg")
COMPILE_FILE = "build.sh"
BENCH_DIR="benchmarks"

def git(*args):
    return subprocess.check_call(['git'] + list(args))

def svn(*args):
    return subprocess.check_call(['svn'] + list(args))

def insert_content_to_file(filename, index, value):
    """
    insert the content to the index lines

    :param filename: the file will be modified
    :param index: the location eill added the value
    :param vale: the content will be added
    """
    f = open(filename, "r")
    contents = f.readlines()
    f.close()

    contents.insert(index, value)

    f= open(filename, "w")
    contents = "".join(contents)
    f.write(contents)
    f.close()

def find_benchmark(filename, version):
    """
    check if the benchmarks contained by the benchmarks

    this function should be more
    """
    flag = 0
    benchs_dir = os.path.join(CALIPER_DIR, BENCH_DIR)
    current_bench = os.path.join(benchs_dir, filename)
    if os.path.exists(current_bench):
        flag = 1
    if os.path.exists(os.path.join(CALIPER_DIR, filename)):
        flag = 1
    bench_dir = ''
    if not version:
        # have not information about the version
        listfile = os.listdir(benchs_dir)
        for line in listfile:
            if re.search(filename, line, re.IGNORECASE):
                flag = 1
                bench_dir = line
    return [bench_dir, flag ]

def generate_build(config, dir_name, build_file):
    """
    generate the final build.sh
    :param config: means the config file for selecting which test case will be run
    param: dir_name: indicate the directory name, such as 'common', 'server' and others
    param: build_file: means the final build.sh
    """

    sections = config.sections()
    for i in range(0, len(sections)):
        try:
            version = config.get(sections[i], 'version')
        except BaseException:
            version = ""
            #print "No option of Version"
        if version:
            filename = sections[i] + '_' + version
        else:
            filename = sections[i]
        """we think that if we store the benchmarks in the directory of benchmarks, we need not
        download the benchmark. if the benchmarks are in the root directory of Caliper, we think
        it is temporarily, after compiling we will delete them."""

        ben_dir, exist = find_benchmark(filename, version)
        """how to use the ben_dir to build the benchmark"""
        if not exist:
            try:
                download_url = config.get(sections[i], 'download_cmd')
            except BaseException:
                print "We don't have the benchmarks, you should provide a link to git clone"
                continue
            url_list = download_url.split(" ")
            # need to expand here
            exit = git(url_list[1], url_list[2])
            if ( exit != 0 ):
                print "Download the benchmark of %s failed" % filename
                continue

        try:
            tmp_build = config.get(sections[i], 'build')
        except BaseException:
            """NoSectionError:"""
            tmp_build = ""

        """add the build file to the build.sh; maybe the function is not in the config
        file, then we can find it in the build.sh, if the build option in it, we add it;
        else we give up the build of it."""
        location = -2
        if tmp_build:
            build_command = os.path.join(TEST_CFG_DIR, dir_name, sections[i], tmp_build)
            file_path = "source " + build_command  +"\n"
            insert_content_to_file(build_file, location, file_path)
        else:
            source_fp = open(build_file, "r")
            all_text = source_fp.read()
            source_fp.close()
            func_name = 'build_'+ sections[i]
            if re.search(func_name, all_text):
                value = func_name + "  \n"
                insert_content_to_file(build_file, location, value)

""" For 'android', we need to read the 'common_cases_def.cfg' and 'common_case_def.cfg';
    For 'arm', need to read the 'common_case_def.cfg' and 'arm_cases_def.cfg';
    For 'x86', need to read the 'common_case_def.cfg' and 'server_cases_def.cfg'.    """
def get_cases_def_files( option ):
    cfg_files = []
    cases_tail = "_cases_def.cfg"
    common_cfg = "common" + cases_tail
    common_cfg_path = os.path.join(TEST_CFG_DIR, common_cfg)
    cfg_files.append(common_cfg_path)
    if ( option == 'arm_64' or option == 'arm_32' ):
        other_cfg = "arm" + cases_tail
    elif (option == 'android'):
        other_cfg = "android" + cases_tail
    else:
        other_cfg =  'server' + cases_tail
    other_cfg_path = os.path.join(TEST_CFG_DIR, other_cfg)
    cfg_files.append(other_cfg_path)
    return cfg_files

def generate_kinds_build(source_build_file, des_build_file, files_list):
    for i in range(0, len(files_list)):
        config = ConfigParser.ConfigParser()
        config.read(files_list[i])

        #get the directory, such as 'common','server' and so on
        dir_name = files_list[i].strip().split("/")[-1].strip().split("_")[0].strip()
        try:
            generate_build(config, dir_name, des_build_file )
        except Exception, e:
            print e

def build_caliper(target_arch):
    if target_arch:
        arch = target_arch
    else:
        arch = 'x86_64'
    # get the files list of 'cfg'
    cases_file = []
    cases_file = get_cases_def_files( arch )
    logging.info("config files are %s" %  cases_file)

    build_script_dir = os.path.join(CALIPER_DIR, "server", "build")
    source_build_file = os.path.join(build_script_dir, "build.sh")
    print source_build_file
    pwd = os.getcwd()
    des_build_file = os.path.abspath( os.path.join(pwd, COMPILE_FILE) )
    logging.info("destination file of building is %s" % des_build_file)

    if os.path.exists(des_build_file):
        if os.path.abspath(des_build_file) != os.path.abspath(source_build_file):
            os.remove(des_build_file)
    if os.path.abspath(source_build_file) != os.path.abspath(des_build_file):
        shutil.copyfile(os.path.abspath(source_build_file), des_build_file )
   
    try:
        logging.info("begining to generate the final build.sh")
        generate_kinds_build(source_build_file, des_build_file, cases_file)
    except Exception, e:
        print e
   
    os.chmod( des_build_file, stat.S_IRWXO + stat.S_IRWXU + stat.S_IRWXG )
    logging.debug("begin to build the whole test suite")
    result = subprocess.call("./build.sh %s" % arch, shell=True)
    if result:
        logging.info("There is error when build the benchmarks")
    if os.path.isfile(des_build_file):
        if os.path.abspath(des_build_file) != os.path.abspath(source_build_file):
            os.remove(des_build_file)

def build_for_target(target):
    target_arch = server_utils.get_host_arch(target)
    try:
        build_caliper(target_arch)
    except Exception,e:
        raise
    try:
        result = target.run("test -d caliper", ignore_status=True)
    except error.ServRunError, e:
        raise
    else:
        if not result.exit_status:
            target.run("cd caliper; rm -fr *; cd")
        else:
            target.run("mkdir caliper")

        remote_pwd = target.run("pwd").stdout
        remote_pwd = remote_pwd.split("\n")[0]
        remote_caliper_dir = os.path.join(remote_pwd, "caliper")
        send_files = ['client', 'common.py', 'gen', '__init__.py']
       
        os.chdir(CALIPER_DIR)
        for i in range(0, len(send_files)):
            try:
                target.send_file(send_files[i], remote_caliper_dir)
            except Exception, e:
                logging.info("There is error when coping files to remote %s" % target.ip)
                print e
        #os.chdir(CURRENT_PATH)
        logging.info("finished the scp caliper to the remote host")

def build_for_local():
    arch = server_utils.get_local_machine_arch()
    #pdb.set_trace()
    logging.info("arch of the local host is %s" % arch)   
    arch_dir = os.path.join(GEN_DIR, arch)
    if os.path.exists(arch_dir):
        shutil.rmtree(arch_dir)
   
    try:
        build_caliper(arch)
    except Exception, e:
        raise Exception(e.args[0], e.args[1])
    else:
        return

if __name__=="__main__":
    build_for_local()
