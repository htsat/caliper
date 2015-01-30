## wuyanjun  00291783  wu.wu@hisilicon.com
import re
import string
import pdb

def parser(content, option, outfp):
    score = 0
    for lines in re.findall("=+LINUX\s+DATA\s+BELOW\s*=+\n(.*?)\n\*\s+Trademarks", content, re.DOTALL):
        if lines :
            line_list = lines.splitlines()
            for i in range(0, len(line_list)):
                if re.search("MEMORY\s+INDEX", line_list[i]):
                    memory_line = line_list[i]
                elif re.search("INTEGER\s+INDEX", line_list[i]):
                    int_line = line_list[i]
                else:
                    if re.search("FLOATING-POINT", line_list[i]):
                        float_line = line_list[i]
            if option == "int":
                line_list.remove(memory_line)
                line_list.remove(float_line)
                score = int_line.split(":")[1].strip()
            elif option == "float":
                line_list.remove(int_line)
                line_list.remove(memory_line)
                score = float_line.split(":")[1].strip()
            else:
                if option == "memory":
                    line_list.remove(int_line)
                    line_list.remove(float_line)
                    score = memory_line.split(":")[1].strip()

            for i in range(0, len(line_list)):
                outfp.write(line_list[i] + '\n')
            print score
            return score

def nbench_int_parser(content, outfp):
    score = -1
    score = parser(content, "int", outfp)
    return score

def nbench_float_parser(content, outfp):
    score = -1
    score = parser(content, "float", outfp)
    return score

if __name__=="__main__":
    infp = open("1.txt", "r")
    outfp = open("2.txt", "a+")
    content = infp.read()
    #pdb.set_trace()
    nbench_int_parser(content, outfp)
    outfp.close()
    outfp = open("3.txt", "a+")
    nbench_float_parser(content, outfp)
    outfp.close()

