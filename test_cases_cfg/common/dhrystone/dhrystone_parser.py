import re
import pdb

def whets_parser(content, outfp):
    score = -1
    lines = content.splitlines()
    for i in range(0, len(lines)):
        if re.search("MWIPS", lines[i]):
             line = lines[i]
             fields = line.split()
             score = fields[1]
             print score
             outfp.write(str(score) +'\n')
    return score

if __name__=="__main__":
    infp = open ("1.txt", "r")
    content = infp.read()

    outfp = open("2.txt", "a+")
    pdb.set_trace()
    whets_parser(content, outfp)

    outfp.close()
    infp.close()

