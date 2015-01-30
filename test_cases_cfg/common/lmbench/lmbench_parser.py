import re
import string
import math
import pdb
import types
import sys

def get_value(tags, key_tags, content, outfp):
    flag = -1
    for i in range(0, len(tags)):
        if re.search(tags[i], content):
            flag = 0
            for line in content.splitlines():
                if re.search('seconds', line):
                    score_string = line.split(":")[-1].strip()
                    score = score_string.split()[0]
                    if string.atof(score):
                        outfp.write(key_tags[i] + ": "+ score_string + "\n")
                        return score
            outfp.write(key_tags[i] + ": 0\n")
            return flag
    return flag

def syscall_latency_parser(content, outfp):
    tags = ["null", "read", "write", "fstat", "stat", "open" ]
    key_tags = ["lat_sys_null", "lat_sys_read", "lat_sys_wr", "lat_sys_fstat", "lat_sys_stat", "lat_sys_open/close"]
   
    tags_sig = ["install", "catch"]
    key_tags_sig = ["lat_sig_install", "lat_sig_catch"]

    tags_proc = ["fork\+exit", "fork\+execve", "shell"]
    key_tags_proc = ["lat_proc_fork", "lat_proc_exec", "lat_proc_shell"]

    score = 0
    if re.search("lat_syscall", content):
        score = get_value(tags, key_tags, content, outfp)
    elif re.search("lat_sig", content):
        score = get_value(tags_sig, key_tags_sig, content, outfp)
    elif re.search("lat_proc", content):
        score = get_value(tags_proc, key_tags_proc, content, outfp)
    else:
        score = -1
    return score

def network_latency_parser(content, outfp):
    tags_net = ["lat_pipe", "lat_unix", "lat_udp", "lat_tcp", "lat_connect"]
    score = 0
    score = get_value(tags_net, tags_net, content, outfp)
    return score

def get_last_num(content ):
    score = 0
    for line in re.findall("log:(.*?)\n(.*?)\[status\]", content, re.DOTALL):
        print line
    lines = content.splitlines()
    for i in range(len(lines)-1, -1, -1):
        fields = lines[i].split()
        if len(fields):
            field = []
            for x in fields:
                try:
                    num = string.atof(x)
                    field.append(num)
                except BaseException:
                    continue
            if len(field):
                return field[-1]
    return score

def memory_speed_parser(content, outfp):
    score = 0
    if re.search(r"bw_mem.*\brd\b", content):
        score = get_last_num(content)
        outfp.write("bw_mem_rd: "+ str(score) + "\n")
    elif re.search(r"bw_mem.*\bwr\b", content):
        score = get_last_num(content)
        outfp.write("bw_mem_wr: "+ str(score) + "\n" )
    elif re.search(r"bw_mem.*\brdwr\b", content):
        score = get_last_num(content)
        outfp.write("bw_mem_rdwr: "+str(score) + "\n")
    elif re.search(r"bw_mem.*\bbzero\b.?", content):
        score = get_last_num(content)
        outfp.write("bw_mem_bzero: "+str(score) + "\n")
    elif re.search(r"bw_mem.*\bbcopy\b", content):
        if not re.search(r"bw_mem.*\bbcopy\b\sconflict", content):
            score = get_last_num(content)
            outfp.write("bw_mem_bcopy: "+str(score) + "\n")
        else:
            score = -1
    else:
        score = -1

    return score

if __name__ == "__main__":
    infp = open(sys.argv[1], 'r')
    outfp = open("tmp.log", "w+")
    content = infp.read()
    syscall_latency_parser(content, outfp)
    network_latency_parser(content, outfp)
    memory_speed_parser(content, outfp)
    outfp.close()
    infp.close()

