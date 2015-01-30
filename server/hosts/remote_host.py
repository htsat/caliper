#!/usr/bin/env python
# -*- coding:utf-8 -*-
#
#   Author  :   wuyanjun 00291783
#   E-mail  :   wu.wu@hisilicon.com
#   Date    :   14/12/30 20:14:55
#   Desc    :  
#

import os
import sys
import logging
import urllib

from caliper.client.shared import error
from caliper.server.hosts import basic_host, install_server
from caliper.server import utils

DEFAULT_HALT_TIMEOUT=50
DEFAULT_REBOOT_TIMEOUT=120
LAST_BOOT_TAG=None

class RemoteHost(basic_host.Host):
    """
    this class means a remote machine on which you can run programs

    it may be accessed through a network, a serial line, ...
    """
    VAR_LOG_MESSAGES_COPY_PATH = "/var/tmp/messages.caliper_start"
   
    VAR_LOG_MESSAGES_PATHS = ["/var/log/messages", "/var/log/syslog"]

    INSTALL_SERVER_MAPPING = {'cobbler': install_server.CobblerInterface}

    def _initialize(self, hostname, autodir=None, profile='', *args, **dargs):
        super(RemoteHost, self)._initialize(*args, **dargs)
        self.hostname = hostname
        self.autodir = autodir
        self.profile = profile
        self.tmp_dirs = []

    def __repr__(self):
        return "<remote host: %s, profile: %s>" % (self.hostname, self.profile)

    def close():
        super(RemoteHost, self).close()
        self.stop_loggers()

        if hasattr(self, 'tmp_dirs'):
            for dir in self.tmp_dirs:
                try:
                    self.run('rm -fr "%s"' % utils.sh_escape(dir))
                except error.AutoError:
                    pass

    def _var_log_messages_path(self):
        """
        Find possible paths for a message file
        """
        for path in self.VAR_LOG_MESSAGES_PATHS:
            try:
                self.run('test -f %s' % path)
                logging.debug("Found remote path %s" % path)
                return path
            except:
                logging.debug("Remote path %s is missing", path)

        return None

    def job_start(self):
        """
        abstract method, when the remote host object is created
        and a job on it starts, it will be called
        """
        messages_file = self._var_log_messages_path()
        if messages_file is not None:
            try:
                self.run('rm -fr %s' % self.VAR_LOG_MESSAGES_COPY_PATH)
                self.run('cp %s %s' % (messages_file, self.VAR_LOG_MESSAGES_COPY_PATH))
            except Exception, e:
                logging.info('Failed to copy %s at startup: %s', messages_file, e)
        else:
            logging.info("No remote messahes path found, looked %s", self.VAR_LOG_MESSAGES_COPY_PATH)

    def get_autodir(self):
        return self.autodir

    def set_autodir(self, autodir):
        """
        this method is called to make the host object aware of where to install the Caliper.
        """
        self.autodir = autodir

    def sysrq_reboot(self):
        self.run('echo b > /proc/sysrq-trigger &')

#    def halt(self, timeout=DEFAULT_HALT_TIMEOUT, wait=True):
#        self.run('/sbin/halt')
#        if wait:
#            self.wait_down(timeout=timeout)
#
#    def reboot(self, timeout=DEFAULT_REBOOT_TIMEOUT, label=LAST_BOOT_TAG,
#            kernel_args=None, wait=True, fastsync=False,
#            reboot_cmd=None, **dargs):
#        """
#        Reboot the remote host.
#
#        Args:
#            timeout - how long to wait for the reboot.
#            label - the label we should boot into. If none, we will boot into the default kernel.
#                    If it's LAST_BOOT_TAG, we'll boot into whichever kernel was .boot'ed last.
#            wait - should we wait to see if the machine comes back up.
#            fastsync - Don't wait for the sync tp complete, just start one and move on.
#        """
#        if self.job:
#            if label == self.LAST_BOOT_TAG:
#                label = self.job.last_boot_tag
#            else:
#                self.job.last_boot_tag = label
#
#        self.reboot_setup(label=label, kernel_args=kernel_args, **dargs)
#
#        if label or kernel_args:
#            if not label:
#                label = self.bootloader.get_default_title()
#            self.bootloader.boot_once(label)
#            if kernel_args:
#                self.bootloader.add_args(label, kernel_args)
#
#        # define a function for the  reboot and run it in a group
#        print "Reboot: initiating reboot"
#
#        def reboot():
#            self.record("Good", None, "reboot.start")
#            try:
#                current_boot_id = self.get_boot_id()
#
#                # sync before starting the reboot, so that a long sync during
#                # shutdown isn't timed out by wait_down's short timeout
#
#                if not fastsync:
#                    self.run('sync; sync', timeout=timeout, ignore_status=True)
#
#                if reboot_cmd:
#                    self.run(reboot_cmd)
#                else:
#                    # Try several methods of rebooting in increasing harshness
#                    self.run('(('
#                                ' sync & '
#                                ' sleep 5; reboot & '
#                                ' sleep 60; reboot -f & '
#                                ' sleep 10; reboot -nf & '
#                                ' sleep 10; telinit 6 & '
#                                ') </dev/null >/dev/null 2>&1 &)')
#            except error.AutoError:
#                self.record("ABORT", None, "reboot.start", "reboot command failed")
#                raise
#
#            if wait:
#                self.wait_for_restart(timeout, old_boot_id=current_boot_id, **dargs)
#           
#        # if this is a full reboot-and-wait, run the reboot inside a group
#        if wait:
#            self.log_reboot(reboot)
#        else:
#            reboot()
#
#    def reboot_followup(self, *args, **dargs):
#        super(RemoteHost, self).reboot_followup(*args, **dargs)
#        if self.job:
#            self.job.profiles.handle_reboot(self)
#
#    def wait_for_restart(self, timeout=DEFAULT_REBOOT_TIMEOUT, **dargs):
#        """
#        Wait for the host come back from a reboot. This wraps the generic wait_for
#        restart implementatuon in a reboot group
#        """
#        def reboot_func():
#            super(RemoteHost, self).wait_for_restart(timeout=timeout, **dargs)
#        self.log_reboot(reboot_func)
#
#    def cleanup(self):
#        super(RemoteHost, self).cleanup()
#        self.reboot()

    def get_tmp_dir(self, parent='/tmp'):
        """
        return the pathname of a directory on the host suitable
        for temporary file storage
        The directory and its content will be deleted automaticallu on the
        destruction of the Host object that was used to obtain it.
        """
        self.run("mkdir -p %s" % parent)
        template = os.path.join(parent, 'caliper-XXXXXX')
        dir_name = self.run("mktemp -d %s" % template).stdout.rstrip()
        self.tmp_dirs.append(dir_name)
        return dir_name

    def get_platform_label(self):
        """
        Return the platform label, or None if platform label is not set.
        """
        if self.job:
            keyval_path = os.path.join(self.job.resultdir, 'host_keyvals',
                                        self.hostname)
            keyvals = utils.read_keyval(keyval_path)
            return keyvals.get('platform', None)
        else:
            return None

    def get_all_labels(self):
        """
        Return all labels, or empty list if label is not set
        """
        if self.job:
            keyval_path = os.path.join(self.job.resultdir, 'host_keyvals',
                                        self.hostname)
            keyvals = utils.read_keyval(keyval_path)
            all_labels = keyvals.get('labels', '')
            if all_labels:
                all_labels = all_labels.split(',')
                return [urllib.unquote(label) for label in all_labels]
        return []

    def delete_tmp_dir(self, tmpdir):
        """
        delete the given temporary directory on the remote machine
        """
        self.run('rm -fr "%s"' % utils.sh_escape(tmpdir), ignore_status=True )
        self.tmp_dirs.remove(tmpdir)

    def check_uptime(self):
        """
        Check that uptime is available and monotonically increasing
        """

        if not self.is_up():
            raise error.ServHostError('Client does not appear to be up')
        result = self.run("/bin/cat /proc/uptime", 30)
        return result.stdout.strip().split()[0]

#    def are_wait_up_processes_up(self):
#        """
#        Checks if any HOSTS waitup processes are running yes on the remote host.
#        Return True if any the waitup processes are running, False otherwise.
#        """
#        processes = self.get_wait_up_processes()
#        if len(processes) == 0:
#            return True
#        for procname in processes:
#            exit_status = self.run("{ ps -e || ps ;} | grep '%s'" % procname,
#                                    ignore_status=True).exit_status
#            if exit_status == 0:
#                return True
#        return False
#
