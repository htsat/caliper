import re
import string
import sys
import os
import math

def generate_value(content, outfp):
    keylist = {}
    labels = ["^md5", "^sha1", "^des cbc", "^des ede3", "sha256", "sha512", "aes-128 ige",
            "^aes-192 ige", "aes-256 ige", "^rsa 2048", "^dsa 2048"]
    keys = ["md5_speed", "sha1_speed", "des_speed", "3des_speed", "sha256_speed", "sha512_speed", "aes128_speed", "aes192_speed", "aes256_speed", "rsa_2048_sign", "rsa_2048_verify", "dsa_2048_sign", "dsa_2048_verify"]

    for line in content.splitlines():
        for i in range(0, len(labels)):
            if re.search(labels[i], line):
                label = labels[i]
                field = line.split()
                if (label == labels[-1]):
                    keylist[keys[-2]] = field[-2]
                    keylist[keys[-1]] = field[-1]
                    outfp.write(keys[-2] + ": "+keylist[keys[-2]]+'\n')
                    outfp.write(keys[-1] + ": "+keylist[keys[-1]]+'\n')
                elif (label == labels[-2]):
                    keylist[keys[-4]] = field[-2]
                    keylist[keys[-3]] = field[-1]
                    outfp.write(keys[-4] + ": "+keylist[keys[-4]]+'\n')
                    outfp.write(keys[-3] + ": "+keylist[keys[-3]]+'\n')
                else:
                    keylist[keys[i]] = field[-2].split("k")[0]
                    outfp.write(keys[i] + ": "+keylist[keys[i]]+'\n')

    return keylist
       
def parser1(content, outfp):
#need to standardization
   
    for line in content.splitlines():
        if re.search("^OpenSSL", line):
            outfp.write(line+'\n')
        elif re.search("^options", line):
            outfp.write(line+'\n')
        elif re.search("^compiler", line):
            outfp.write(line+'\n')
        else:
            pass

    key_list = generate_value(content, outfp)


    value_list = key_list.values()
    values = []
    for i in range(0, len(key_list)):
        try:
            values.append(string.atof(value_list[i]))
        except ValueError:
            continue
	try:
		value_float = [float(value) for value in values if value != 0]
	except ValuError:
		return None
	product = 1
	n = len(value_float)
	if n ==0:
		result = 1
	result = math.exp(sum([math.log(x) for x in values]) / n)
    #result = geometric_mean(values)
    print result
    return result

if __name__=="__main__":
    infile = "openssl_output.log"
    outfile = "openssl_parser.log"
    infp = open(infile, "r")
    outfp = open(outfile, "a+")
    content = infp.read()
    parser1(content, outfp)
    outfp.close()
    infp.close()
