## wuyanjun w00291783
## wu.wu@hisilicon.com
## copyright

import ConfigParser
import os
import sys
#sys.path.append(os.path.abspath("../"))
import time
import shutil
import importlib
import yaml
#import math
import types
import string
import re
import pdb
import logging
#sys.path.append(os.path.abspath("../../"))

try:
    import caliper.common as common
except ImportError:
    import common

from caliper.server.compute_model.scores_method import Scores_method
from caliper.client.shared import error
from caliper.server import utils as server_utils
from caliper.client.shared import utils

TEST_CFG_DIR='test_cases_cfg'

def file_copy(des_file, source_file, style):
    des_fp = open(des_file, style)
    source_fp =open(source_file, 'r')
    content = source_fp.read()
    des_fp.write( content )
    source_fp.close()
    des_fp.close()

def read_config_file(filename):
    config = ConfigParser.ConfigParser()
    config.read(filename)
    sections = config.sections()
    return (config, sections)

def get_server_command(caliper_root, classify, bench_name, section_name):
   
    server_config_file = ''
    bench_conf_dir = os.path.join(caliper_root, TEST_CFG_DIR, classify, bench_name)

    for root, dirs, files in os.walk( os.path.abspath(bench_conf_dir) ):
        for i in range(0, len(files)):
            if re.search('server', files[i]):
                server_config_file = os.path.join(root, files[i])
                break
    if server_config_file != '':
        server_config, server_sections = read_config_file(server_config_file)
        if section_name in server_sections:
            command = server_config.get(section_name, 'command')
            print command
            return command
        else:
            return None
    else:
        return None

def run_all_cases(caliper_dir, serv_exec_dir, target, classify, bench_name, run_file, parser):
    """
    function: run one benchmark which was selected in the configuration files

    :param config: the configuration file for selecting benchmarks
    """
    #get the abspath, which is the file name of run config for the benchmark
    bench_conf_file = os.path.join(caliper_dir, TEST_CFG_DIR, classify,
                                    bench_name,  run_file)
    #get the config sections for the benchmrk
    configRun, sections_run = read_config_file(bench_conf_file)
    print sections_run

    logfile = bench_name + "_output.log"
    tmp_log_file = bench_name + "_output_tmp.log"
    parser_result_file = bench_name + "_parser.log"
    tmp_parser_file = bench_name + "_parser_tmp.log"

    #for each command in run config file, read the config for the benchmark
    for i in range(0, len(sections_run)):
        flag = 0
        try:
            category = configRun.get(sections_run[i], 'category')
            scores_way = configRun.get(sections_run[i], 'scores_way')
            parser = configRun.get(sections_run[i], 'parser')
            command = configRun.get(sections_run[i], 'command')
        except Exception:
            print "no value for the %s" % sections_run[i]
            continue

        if os.path.exists(tmp_parser_file):
            os.remove(tmp_parser_file)
        if os.path.exists(tmp_log_file):
            os.remove(tmp_log_file)
       
        server_run_command = get_server_command(caliper_dir, classify,
                                                bench_name, sections_run[i])
        logging.info("Get the server command is: %s" % server_run_command)
        ## run the command of the benchmarks
        try:
            if server_run_command != '' and server_run_command is not None:
                logging.info("Running the server_command: %s, and the client command: %s" %
                                            (server_run_command, command))
                flag = run_case(sections_run[i], server_run_command, tmp_log_file,
                                serv_exec_dir, bench_name, classify, target, command)
            else:
                logging.info("only running the command %s in the remote host" % command)
                flag = run_client_command(sections_run[i], tmp_log_file, bench_name,
                        classify, target, command)
        except Exception, e:
            print e
            continue
        else:
            file_copy(logfile, tmp_log_file, 'a+')
            if (flag == 1):
                # parser the result in the tmp_log_file, the result is the output of running the command
                try:
                    logging.info("Parsering the result of command: %s" % command)
                    parser_result = parser_case(bench_name,  parser, serv_exec_dir,
                                                tmp_log_file, tmp_parser_file, classify)
                except Exception, e:
                    print "There is wrong when parsering the result of \" %s \"" % sections_run[i]
                    print e
                else:
                    file_copy(parser_result_file, tmp_parser_file, "a+")
                   
                    if ( parser_result >= 0 ):
                        try:
                            ## according the method in the config file, compute the score
                            logging.info("Computing the score of the result of command: %s" % command)
                            flag_compute = compute_case_score(parser_result, category,
                                                                scores_way, serv_exec_dir, target)
                        except Exception, e:
                            print e
                            continue
                        else:
                            if not flag_compute:
                                print "There is wrong when computing the result of \"%s\"" % command
            else:
                logging.info("There is wrong when running the command \"%s\"" % command)
                continue
    #remove the tmp files, and copy the final files to the 'output' file in the exec directory
    caliper_gen_dir = os.path.join( serv_exec_dir, '..' )
    des_output = caliper_gen_dir + "/output"
    if os.path.exists( os.path.join(des_output, logfile)):
        os.remove(os.path.join(des_output, logfile))
    if os.path.exists(os.path.join(des_output, parser_result_file)):
        os.remove(os.path.join(des_output, parser_result_file))
    shutil.move(logfile, des_output)
    shutil.move(parser_result_file, des_output)
    os.remove(tmp_log_file)
    os.remove(tmp_parser_file)
    # remove the parser file
    pwd_parser = bench_name + "_parser.py"
    pwd_parserc= pwd_parser + 'c'
    if os.path.exists(pwd_parser):
        os.remove(pwd_parser)
    if os.path.exists(pwd_parserc):
        os.remove(pwd_parser+"c")

def run_commands(exec_dir, classify, bench_name, commands,
                    stdout_tee=None, stderr_tee=None):
    returncode = -1
    output = ''
   
    pwd = os.getcwd()
    os.chdir(exec_dir)
    caliper_dir = os.path.abspath(os.path.join(exec_dir, "..", ".."))
    try:
        # the commands is multiple lines, and was included by Quotation
        if commands[0] == '\''  or commands[0] == '\"':
            actual_commands = commands[1:-1]
            try:
                logging.debug("the actual commands running is: %s" % actual_commands)
                result = utils.run(actual_commands, stdout_tee=stdout_tee,
                                    stderr_tee=stderr_tee, verbose=True)
            except error.CmdError, e:
                raise error.ServRunError(e.args[0], e.args[1])
        #elif re.search('\.py', commands ) or re.search('\.sh', commands):
        #    script_file_path = os.path.join(caliper_dir, TEST_CFG_DIR,  classify, bench_name, commands)
        #    if re.search(".*?\.py", commands):
        #        try:
        #            result = utils.run("python %s" % script_file_path, stdout_tee=stdout_tee,
        #                                    stderr_tee=stderr_tee, verbose=True)
        #        except error.CmdError, e:
        #            raise error.ServRunError(e.args[0], e.args[1])
        #    else:
        #        if re.search(".*?\.sh", commands):
        #            try:
        #                result = utils.run("%s %s" % (shell_path, script_file_path),
        #                                    stdout_tee= stdout_tee, stderr_tee=stderr_tee, verbose=True)
        #            except error.CmdError, e:
        #                raise error.ServRunError(e.args[0], e.args[1])
        else:
            try:
                result = utils.run(commands, stdout_tee=stdout_tee, stderr_tee=stderr_tee,
                                        verbose=True)
            except error.CmdError, e:
                raise error.ServRunError(e.args[0], e.args[1])
    except Exception, e:
        logging.info( e )
    else:
        returncode = result.exit_status
        try:
            output = result.stdout
        except Exception:
            output = result.stderr
    os.chdir(pwd)
    return [output, returncode]

# deal with the commands for the remote host
def get_actual_commands(commands, exec_dir):
    if commands is None or commands=='':
        return None

    if commands[0] == '\'' and commands[-1] == '\'':
        actual_commands = commands[1:-1]
    elif commands[0] == '\"' and commands[-1] == '\"':
        actual_commands = commands[1:-1]
    else:
        actual_commands = commands

    #if not actual_commands.startswith(r'./'):
    #    actual_commands = './'+commands

    if actual_commands == '':
        return ''
    #if not re.match('^\w.*?\w$', actual_commands):
    #    return ''

    #final_commands = os.path.join(exec_dir, actual_commands)
    final_commands = "cd %s; %s" % (exec_dir, actual_commands)
    logging.info("The final command is %s" % final_commands)
    return final_commands

def run_remote_commands(exec_dir, classify, bench_name, commands, target,
                    stdout_tee=None, stderr_tee=None):
    returncode = -1
    output = ''

    try:
        # the commands is multiple lines, and was included by Quotation
        final_commands = get_actual_commands(commands, exec_dir)
        if final_commands is not None and final_commands != '':
            logging.debug("the actual commands running on the remote host is: %s" % final_commands)
            result = target.run(final_commands, stdout_tee=stdout_tee,
                                stderr_tee=stderr_tee, verbose=True)
        else:
            return ['Not command specifited', -1]
    except error.CmdError, e:
        raise error.ServRunError(e.args[0], e.args[1])
    except Exception, e:
        logging.info( e )
    else:
        returncode = result.exit_status
        try:
            output = result.stdout
        except Exception:
            output = result.stderr
    return [output, returncode]

def run_client_command(tag, tmp_logfile, bench_name, classify, target, command):
    fp = open(tmp_logfile, "a+")
    start_log = "%%%%%%            %s test start             %%%%%% \n" % tag
    fp.write(start_log)
    fp.write("<<<BEGIN TEST>>>\n")
    tags = "[test: " + tag + "]\n"
    fp.write(tags)
    logs = "log: " + command + "\n"
    fp.write(logs)
    start = time.time()
    flag = 0
    #command = caliper_dir + "/" + command
    logging.info( "the client running command is %s" % command)
 
    # get the execution location in the remote host
    host_current_pwd = target.run("pwd").stdout.split("\n")[0]
    arch = server_utils.get_host_arch(target)
    host_exec_dir = os.path.join(host_current_pwd, 'caliper', "gen", arch)

    try:
        logging.info("begining to execute the command of %s on the remote host" % command)
        [out, returncode] = run_remote_commands(host_exec_dir, classify, bench_name, command,
                                            target, fp, fp)
    except error.ServRunError, e:
        fp.write( "[status]: FAIL\n")
        #sys.stdout.write(out)
        sys.stdout.write(e)
        flag = -1
    else:
        fp.write( "[status]: PASS\n")
        #sys.stdout.write(out)
        sys.stdout.write("%s finished\n" % command)
        flag = 1

    end = time.time()
    interval = end - start
    fp.write("Time in Seconds: %.3fs\n" % interval)
    fp.write("<<<END>>>\n")
    fp.write("%%%%%% test_end %%%%%%\n\n")
    fp.close()
    return flag

def run_server_command(serv_exec_dir, classify, bench_name, server_command):
    try:
        logging.info("the server running command is %s" % server_command)
        return_code = run_commands(serv_exec_dir, classify, bench_name, server_command )
    except Exception, e:
        logging.info("There is wrong with running the server command: %s" % server_command)
        print e
        os._exit(return_code)
    os._exit(0)

def run_case(tag, server_command, tmp_logfile, serv_exec_dir, bench_name,
                classify, target, command):
    if server_command is None or server_command=='':
        return
    if command is None or command =='':
        return

    while True:
        newpid = os.fork()
        logging.info("the pid number is %d" % newpid)
        if newpid == 0:
            run_server_command(serv_exec_dir, classify, bench_name, server_command)
        else:
            time.sleep(10)
            #pdb.set_trace()
            logging.info("the pid number of parent is %d" % os.getpid())
            logging.info("the pid number of child is %d" % newpid)
            try:
                return_code = run_client_command(tag, tmp_logfile, bench_name,
                        classify, target, command)
            except Exception, e:
                logging.info("There is wrong with running the remote host command of %s" % command)
                logging.info(e.args[0], e.args[1])
                utils.kill_process_tree(newpid)
            else:
                utils.kill_process_tree(newpid)
                return return_code
    return 0

def parser_case(bench_name, parser, exec_dir, infile, outfile, classify):
    if not os.path.exists(infile):
        return -1
   
    result = 0
    fp = open(outfile, "w")
    #sys.stdout = fp
   
    caliper_dir = os.path.abspath(os.path.join(exec_dir, "..", ".."))
    #the parser function defined in the config file is to filter the output.
    # get the abspth of the parser.py which is defined in the config files.
    pwd_file = bench_name + "_parser.py"
    parser_file = os.path.join(caliper_dir, TEST_CFG_DIR,  classify, bench_name, pwd_file)
    if not os.path.exists(parser_file):
        fp.write("There is no such a file %s \n" % parser_file)
        sys.sdtout.write("There is no such a file %s \n" % parser_file)
        return -2
    # copy the parser files to the cwd path to import it.
   
    pwd_parser = pwd_file.split(".")[0]
    shutil.copyfile(parser_file, pwd_file)
   
    if os.path.isfile(parser_file):
        try:
            # import the parser module import_module
            parser_module = importlib.import_module(pwd_parser)
        except ImportError, e:
            print e
            return -3

        try:
            methodToCall = getattr(parser_module, parser)
        except Exception, e:
            print e
            return -4
        else:
            infp = open(infile, "r")
            outfp = open(outfile, 'a+')
            contents = infp.read()
            for content in re.findall("log:(.*?)\[status\]", contents, re.DOTALL):
                try:
                    # call the parser function to filter the output
                    logging.info("Begining to parser the result of the case")
                    result = methodToCall(content, outfp)
                except Exception, e:
                    print e
                    return -5
            outfp.close()
            infp.close()
    fp.close()

    return result

def compute_case_score(result, category, score_way, exec_dir, target):
    tmp = category.split()
    length = len(tmp)
    if (length != 4):
        return -3
   
    result_flag = 1
    score_flag = 2
  
    if type(result) is types.StringType:
        result_fp = string.atof(result)
    elif type(result) is types.FloatType:
        result_fp = result
    elif type(result) is types.IntType:
        result_fp = result
    else:
        return -4
    #pdb.set_trace()
    # this part should be improved
    func_args = score_way.split()
    score_method = func_args[0]
    if len(func_args) < 2:
        print "The configuration of run the benchmark is wrong"
        return -5
    base = string.atof(func_args[1])
    if len(func_args) >= 3:
        index = string.atof(func_args[2])
    if score_method == "exp_score_compute":
        if result_fp == 0:
            result_score = 0
        else:
            result_score = Scores_method.exp_score_compute(result_fp, base, index)
            logging.info("After computing, the result is %f" % result_score)
    else:
        if score_method == "compute_speed_score":
            if result_fp == 0:
                result_score = 0
            else:
               result_score = Scores_method.compute_speed_score(result_fp, base)

    #write the result and the corresponding score to files
    target_name = server_utils.get_host_name(target)
    yaml_dir = os.path.join(exec_dir, "..", "output", "yaml")
    result_yaml_name = target_name + '.yaml'
    score_yaml_name = target_name + "_score.yaml"
    result_yaml = os.path.join(yaml_dir, result_yaml_name)
    score_yaml = os.path.join(yaml_dir, score_yaml_name)

    try:
        flag1 = write_yaml(result_yaml, tmp, result_fp, result_flag)
        flag2 = write_yaml(score_yaml, tmp, result_score, score_flag)
    except BaseException:
        print "There is wrong when compute the score."
    return flag1 & flag2

def write_yaml(yaml_file, tmp, result, category):
    flag = 0
    if not os.path.exists(yaml_file):
        os.mknod(yaml_file)
    fp = open(yaml_file)
    x = yaml.load(fp)
    try:
        RES = 'results'
        if not x:
            x = {}
        if RES not in x:
            x[RES] = {}
        if not x[RES]:
            x[RES] = {}
        if tmp[0] not in x[RES]:
            x[RES][tmp[0]] = {}
        if tmp[1] not in x[RES][tmp[0]]:
            x[RES][tmp[0]][tmp[1]] = {}
        if tmp[2] not in x[RES][tmp[0]][tmp[1]]:
            x[RES][tmp[0]][tmp[1]][tmp[2]] = {}
        if category == 1:
            if tmp[3] not in x[RES][tmp[0]][tmp[1]][tmp[2]]:
                x[RES][tmp[0]][tmp[1]][tmp[2]][tmp[3]] = {}
            x[RES][tmp[0]][tmp[1]][tmp[2]][tmp[3]] = result
            flag = 1
        elif category == 2:
            if 'Point_Scores' not in x[RES][tmp[0]][tmp[1]][tmp[2]]:
                x[RES][tmp[0]][tmp[1]][tmp[2]]['Point_Scores'] = {}
            if not x[RES][tmp[0]][tmp[1]][tmp[2]]['Point_Scores']:
                x[RES][tmp[0]][tmp[1]][tmp[2]]['Point_Scores'] = {}
            if tmp[3] not in x[RES][tmp[0]][tmp[1]][tmp[2]]['Point_Scores']:
                x[RES][tmp[0]][tmp[1]][tmp[2]]['Point_Scores'][tmp[3]] = result
                flag = 1
            x[RES][tmp[0]][tmp[1]][tmp[2]]['Point_Scores'][tmp[3]] = result
            flag = 1
        else:
            pass
    except BaseException, e:
        print "There is wrong when write the data in file %s." % yaml
        print e
        flag = -1
    else:
        fp.close()
        with open(yaml_file, 'w') as outfile:
            outfile.write(yaml.dump(x, default_flow_style=False))
        outfile.close()
    return flag

#different options will read the different config files
def get_cases_def_files( direc_name ):
    cfg_files = []
    cases_dir = TEST_CFG_DIR
    cases_tail = "_cases_def.cfg"
    common_cfg = "common" + cases_tail
    common_cfg_path = os.path.join(cases_dir,common_cfg)
    cfg_files.append(common_cfg_path)

    #get the other cfg file name
    option_dir = direc_name.strip().split("/")[-1]
    if ( option_dir == 'arm_64' or option_dir == 'arm_32' ):
        other_cfg = "arm" + cases_tail
    elif (option_dir == 'android'):
        other_cfg = "android" + cases_tail
    else:
        other_cfg = 'server' + cases_tail
    other_cfg_path = os.path.join(cases_dir, other_cfg)
    cfg_files.append(other_cfg_path)
    return cfg_files

def caliper_run(caliper_dir, serv_exec_dir, target):

    # get the test cases defined files
    config_files = get_cases_def_files( serv_exec_dir )
    logging.info("the selected configuration are %s" % config_files)
   
    for i in range(0, len(config_files)):
        # run benchmarks selected in each configuration file
        config_file = os.path.join(caliper_dir, config_files[i])
        config, sections = read_config_file(config_file)
        print sections
        
        #get if it is the 'common' or 'arm' or 'android'
        classify = config_files[i].split("/")[-1].strip().split("_")[0]
        print classify

        for i in range(0, len(sections)):
            # run for each benchmark
            # try to resolve the configuration of the configuration file
            # which selected the test case will be run
            try:
                run_file = config.get(sections[i], 'run')
                parser = config.get(sections[i], 'parser')
            except Exception:
                raise AttributeError("The is no option value of parser")

            try:
                run_all_cases(caliper_dir, serv_exec_dir, target, classify, sections[i], run_file, parser)
            except Exception as ex:
                print "run the benchmark of %s wrong" % sections[i]
                print ex
                continue

if __name__=="__main__":
    caliper_run(sys.argv[1])
