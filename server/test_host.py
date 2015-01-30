#!/usr/bin/env python
# -*- coding:utf-8 -*-
#
#   Author  :   wuyanjun 00291783
#   E-mail  :   wu.wu@hisilicon.com
#   Date    :   15/01/07 10:15:34
#   Desc    :  
#


try:
    import autotest.common as common
except ImportError:
    import common

#import caliper
from caliper.server.hosts import host_factory


if __name__=="__main__":
    server = host_factory.create_host("10.175.102.38", "wuyanjun", "open275249A*", 22)
    file_name='/home/disk/hisi/wuyanjun/123.txt'
    status = server.run("touch '%s'" % file_name)
    status = server.run('echo 123456 > /home/disk/hisi/wuyanjun/123.txt')
    if not status.exit_status:
        #server.disable_ipfilters()
        print "1234"
   
    file_name='/home/disk/hisi/wuyanjun/caliper'
    status = server.send_file("/home/wuyanjun/caliper/client", file_name)
    #if not status.exit_status:
    #    #server.disable_ipfilters()
    #    print "5678"
    file_name='/home/disk/hisi/wuyanjun/123.txt'
    status = server.get_file(file_name, "/home/wuyanjun")
    #if not status.exit_status:
    #    #server.disable_ipfilters()
    #    print "5678"

