#!/usr/bin/env python
# -*- coding:utf-8 -*-
#
#   Author  :   wuyanjun 00291783
#   E-mail  :   wu.wu@hisilicon.com
#   Date    :   15/01/06 20:32:18
#   Desc    :  
#

from caliper.server import utils

class InstallableObject(object):
    """
    this class represents a software package that can be installed on a Host.

    This is a abstract class, leaf subclasses must implement the methods listed here.
    """

    source_material = True
   
    def __init__(self):
        super(InstallableObject, self).__init___()

    def get(self, location):
        """
        get the source material rquired to install the object.
        """
        self.source_material = utils.get(location)

    def install(self, host):
        pass

