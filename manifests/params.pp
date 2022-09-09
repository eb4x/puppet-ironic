#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: ironic::params
#
# Parameters for puppet-ironic
#
class ironic::params {
  include openstacklib::defaults

  $dbsync_command             =
    'ironic-dbsync --config-file /etc/ironic/ironic.conf'
  $inspector_dbsync_command   =
    'ironic-inspector-dbsync --config-file /etc/ironic-inspector/inspector.conf upgrade'
  $client_package             = 'python3-ironicclient'
  $inspector_client_package   = 'python3-ironic-inspector-client'
  $lib_package_name           = 'python3-ironic-lib'
  $group                      = 'ironic'
  $sushy_package_name         = 'python3-sushy'
  $proliantutils_package_name = 'python3-proliantutils'
  $dracclient_package_name    = 'python3-dracclient'

  case $::osfamily {
    'RedHat': {
      $common_package_name       = 'openstack-ironic-common'
      $api_package               = 'openstack-ironic-api'
      $api_service               = 'openstack-ironic-api'
      $conductor_package         = 'openstack-ironic-conductor'
      $conductor_service         = 'openstack-ironic-conductor'
      $dnsmasq_tftp_package      = 'openstack-ironic-dnsmasq-tftp-server'
      $dnsmasq_tftp_service      = 'openstack-ironic-dnsmasq-tftp-server'
      $inspector_package         = 'openstack-ironic-inspector'
      $inspector_dnsmasq_package = 'openstack-ironic-inspector-dnsmasq'
      $inspector_service         = 'openstack-ironic-inspector'
      $inspector_dnsmasq_service = 'openstack-ironic-inspector-dnsmasq'
      $staging_drivers_package   = 'openstack-ironic-staging-drivers'
      $systemd_python_package    = 'systemd-python'
      $ipxe_rom_dir              = '/usr/share/ipxe'
      $ironic_wsgi_script_path   = '/var/www/cgi-bin/ironic'
      $ironic_wsgi_script_source = '/usr/bin/ironic-api-wsgi'
      if (Integer.new($::os['release']['major']) > 8) {
        $xinetd_available        = false
        $tftpd_package           = false
      } else {
        $xinetd_available        = true
        $tftpd_package           = 'tftp-server'
      }
      $ipxe_package              = 'ipxe-bootimgs'
      $syslinux_package          = 'syslinux-tftpboot'
      $syslinux_path             = '/tftpboot'
      $syslinux_files            = ['pxelinux.0', 'chain.c32', 'ldlinux.c32']
    }
    'Debian': {
      $common_package_name       = 'ironic-common'
      $api_service               = 'ironic-api'
      $api_package               = 'ironic-api'
      $conductor_service         = 'ironic-conductor'
      $conductor_package         = 'ironic-conductor'
      $dnsmasq_tftp_package      = false
      $dnsmasq_tftp_service      = false
      $inspector_package         = 'ironic-inspector'
      $inspector_dnsmasq_package = false
      $inspector_service         = 'ironic-inspector'
      $inspector_dnsmasq_service = false
      # guessing the name, ironic-staging-drivers is not packaged in debian yet
      $staging_drivers_package   = 'ironic-staging-drivers'
      $systemd_python_package    = 'python-systemd'
      $ipxe_rom_dir              = '/usr/lib/ipxe'
      $ironic_wsgi_script_path   = '/usr/lib/cgi-bin/ironic'
      $ironic_wsgi_script_source = '/usr/bin/ironic-api-wsgi'
      $xinetd_available          = true
      $tftpd_package             = 'tftpd-hpa'
      $ipxe_package              = 'ipxe'
      $syslinux_package          = 'syslinux-common'
      if ($::os_package_type == 'debian') {
        $syslinux_path = '/usr/lib/syslinux'
      } else {
        $syslinux_path = '/var/lib/tftpboot'
      }
      $syslinux_files            = ['pxelinux.0', 'chain.c32', 'libcom32.c32', 'libutil.c32']
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, \
module ${module_name} only support osfamily RedHat and Debian")
    }
  }

}
