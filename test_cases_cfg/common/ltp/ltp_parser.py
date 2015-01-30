import re
import sys

def ltpResult(content, outfp):
    sumPASS = 0
    sumFail = 0
    score = 0.0
    #pdb.set_trace()
    for m in re.findall("<<<test_start>>>\s*\n(.*?)<<<test_end>>>", content, re.DOTALL):
        if re.search("TFAIL", m):
            sumFail = sumFail + 1
            #print "<<<test_start>>>"
            #print "%s<<<test_end>>>\n" % m
            #print "<<<test_end>>>\n"
        elif re.search("TBROK", 'm'):
            sumFail = sumFail + 1
        elif re.search("TPASS", m):
            sumPASS = sumPASS + 1
        else:
            None
           
    outfp.write('the total number of testcases is %d\n' % (sumPASS + sumFail))
    outfp.write('the tesecases passed are %d, failed are %d\n' % (sumPASS, sumFail))
    try:
        score = (0.0+sumPASS)/(sumPASS + sumFail)
    except Exception, e:
        score = 0.0
    print score
    return score

def ltp_parser(content, outfp):

    score = -1
    score = ltpResult(content, outfp)

if __name__=="__main__":
    fp = open(sys.argv[1], "r")
    text = fp.read()
    outfp = open("2.txt", "a+")
    ltp_parser(text, outfp)
    fp.close()
    outfp.close()
