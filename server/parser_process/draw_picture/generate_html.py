import os
import sys
import shutil
import stat
import pdb

LOCATION = os.path.dirname(sys.modules[__name__].__file__)
CALIPER_DIR = os.path.abspath(os.path.join(LOCATION, '..','..','..'))
GEN_DIR = os.path.join(CALIPER_DIR, 'gen')
HTML_DIR = os.path.join(GEN_DIR, 'output', 'html')

def generate_html():
    pdb.set_trace()
    pwd = os.getcwd()
    os.chdir(LOCATION)
    shutil.copyfile('./get_hardware_info', HTML_DIR + "/get_hardware_info" )
    shutil.copyfile("./html_md", HTML_DIR + "/html_md")
    shutil.copyfile("./configuration_table", HTML_DIR + "/configuration_table")
    os.chdir(HTML_DIR)
    os.chmod("./html_md", stat.S_IRWXU + stat.S_IRWXG + stat.S_IRWXO )
    os.chmod("./get_hardware_info", stat.S_IRWXU + stat.S_IRWXG + stat.S_IRWXO )
    os.system("./html_md")
    os.remove("./get_hardware_info")
    os.remove("./html_md")
    os.remove("./configuration_table")
    os.chdir(pwd)
    #os.remove(OUT_FILE)


if __name__=="__main__":
    generate_html()
