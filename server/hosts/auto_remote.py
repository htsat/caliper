#!/usr/bin/env python
# -*- coding:utf-8 -*-
#
#   Author  :   wuyanjun 00291783
#   E-mail  :   wu.wu@hisilicon.com
#   Date    :   15/01/06 20:02:58
#   Desc    :  
#

import logging
from caliper.server import utils
from caliper.server.hosts import installable_object
from caliper.client.shared.settings import settings

#def _server_system_wide_install():
#    for path in SYSYTEM_WIDE_PATHS:
#        try:
#            os_dep.command(path)
#        except ValueError:
#            return False
#    return True

class BaseAutotest(installable_object.InstallableObject):
    """
    This class represents the auto program. It can be used to run test automatically
    and collect the results.
    """

    def __init__(self, host=None):
        self.host = host
        self.got = False
        self.installed = False
        self.serverdir = utils.get_server_dir()
        #self.os_vendor = client_utils.get_os_vendor()
        #self.server_system_wide_install = _server_system_wide_install()
        super(BaseAutotest, self).__init__()

    install_in_tmpdir = False

    @classmethod
    def get_client_autodir_paths(cls, host):
        return settings.get_value('auto', 'client_autodir_paths', type=list)

    def install(self, host=None, autodir=None):
        self._install(host=host, autodir=autodir)

    def _install(self, host=None, autodir=None, use_auto=True, use_packaging=True):
        """
        Install Caliper.

        :param host: A host instance on which caliper will be installed
        :param autodir: Location on the remote host to install to
        :param use_auto: Enable install modes that depend on the client running with 'autoserv harness'
        :param use_packaging: Enable install modes that use the packaging system
        """
        if not host:
            host = self.host
        if not self.got:
            self.got()
        #
        host.setup()
        logging.info("Installing autotest on %s", host.hostname)

        if self.server_system_wide_install:
            msg_install = ("Caliper seems to be installed in the client on a system wide"
                           " location, proceeding...")
            logging.info("Verifying client package install")

#            if _client_system_wide_install(host):
#                logging.info(msg_install)
#                self.installed = True
#                return
#
#            install_cmd = INSATLL_CLIENT_CMD_MAPPING.get(self.os_vendor, None)
#            if install_cmd is not None:
#                logging.info(msg_install)
#                host.run(install_cmd)
#                if _client_system_wide_install(host):
#                    logging.info("Caliper seems to be installed in the client on a system wide location")
#                    self.installed = True
#                    return
#            raise error.ServError("The caliper client package does not seem to be installed on %s"
#                                    % host.hostname)
#        # set up the caliper directory on the remote machine
#        if not autodir:
#            autodir = self.get_install_dir(host)
#        logging.info('Using installation dir %s', autodir)
#        host.set_autodir(sutodir)
#        host.run('mkdir -p %s' % utils.sh_escape(autodir))
#       
#        # make sure there are no files in $AUTODIR/results
#        results_path = os.path.join(autodir, 'results')
#        host.run('rm -fr %s/*' % utils.sh_escape(results_path), ignore_status=True )
#
#        # Fetch the autotest client from the nearest repository
#        if use_packaging:
#            try:
#                self._install_using_packaging(host, autodir)
