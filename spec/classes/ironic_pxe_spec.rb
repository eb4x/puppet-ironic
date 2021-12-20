require 'spec_helper'

describe 'ironic::pxe' do

  let :default_params do
    { :package_ensure => 'present',
      :tftp_root      => '/tftpboot',
      :http_root      => '/httpboot',
      :ipxe_timeout   => 0,
      :http_port      => 8088, }
  end

  let :params do
    {}
  end

  shared_examples_for 'ironic pxe' do
    let :p do
      default_params.merge(params)
    end

    it 'should contain directory /tftpboot with selinux type tftpdir_t' do
      is_expected.to contain_file('/tftpboot').with(
        'owner'   => 'ironic',
        'group'   => 'ironic',
        'require' => 'Anchor[ironic::config::begin]',
        'ensure'  => 'directory',
        'seltype' => 'tftpdir_t',
      )
    end

    it 'should contain directory /tftpboot/pxelinux.cfg with selinux type tftpdir_t' do
      is_expected.to contain_file('/tftpboot/pxelinux.cfg').with(
        'owner'   => 'ironic',
        'group'   => 'ironic',
        'require' => 'Anchor[ironic::install::end]',
        'ensure'  => 'directory',
        'seltype' => 'tftpdir_t',
      )
    end

    it 'should contain directory /httpboot with selinux type httpd_sys_content_t' do
      is_expected.to contain_file('/httpboot').with(
        'owner'   => 'ironic',
        'group'   => 'ironic',
        'require' => 'Anchor[ironic::config::begin]',
        'ensure'  => 'directory',
        'seltype' => 'httpd_sys_content_t',
      )
    end

    it 'should install tftp-server package' do
      is_expected.to contain_package('tftp-server').with(
        'ensure' => 'present',
      )
    end

    it 'should setup tftp xinetd service' do
      is_expected.to contain_class('xinetd')
      is_expected.to contain_xinetd__service('tftp').with(
       'port'        => '69',
       'protocol'    => 'udp',
       'server_args' => '--map-file /tftpboot/map-file /tftpboot',
       'server'      => '/usr/sbin/in.tftpd',
       'socket_type' => 'dgram',
       'cps'         => '100 2',
       'per_source'  => '11',
       'wait'        => 'yes',
       'subscribe'   => 'Anchor[ironic::install::end]',
      )
    end

    context 'when overriding parameters' do
      before :each do
        params.merge!(
          :tftp_root => '/var/lib/tftpboot',
          :http_root => '/var/www/httpboot',
          :http_port => 3816,
          :tftp_bind_host => '1.2.3.4',
        )
      end

      it 'should contain directory /var/www/httpboot with selinux type httpd_sys_content_t' do
        is_expected.to contain_file('/var/www/httpboot').with(
          'owner'   => 'ironic',
          'group'   => 'ironic',
          'require' => 'Anchor[ironic::config::begin]',
          'ensure'  => 'directory',
          'seltype' => 'httpd_sys_content_t',
        )
      end

      it 'should contain directory /var/lib/tftpboot with selinux type tftpdir_t' do
        is_expected.to contain_file('/var/lib/tftpboot').with(
          'owner'   => 'ironic',
          'group'   => 'ironic',
          'require' => 'Anchor[ironic::config::begin]',
          'ensure'  => 'directory',
          'seltype' => 'tftpdir_t',
        )
      end

      it 'should contain iPXE chainload images' do
        is_expected.to contain_file('/var/lib/tftpboot/undionly.kpxe').with(
          'owner'   => 'ironic',
          'group'   => 'ironic',
          'require' => 'Anchor[ironic-inspector::install::end]',
          'seltype' => 'tftpdir_t',
          'ensure'  => 'file',
          'backup'  => false,
        )
      end
      it 'should contain iPXE UEFI chainload image' do
        is_expected.to contain_file('/var/lib/tftpboot/snponly.efi').with(
          'owner'   => 'ironic',
          'group'   => 'ironic',
          'require' => 'Anchor[ironic-inspector::install::end]',
          'seltype' => 'tftpdir_t',
          'ensure'  => 'file',
          'backup'  => false,
        )
      end

      it 'should setup tftp xinetd service' do
        is_expected.to contain_class('xinetd')
        is_expected.to contain_xinetd__service('tftp').with(
         'port'        => '69',
         'protocol'    => 'udp',
         'server_args' => '--map-file /var/lib/tftpboot/map-file /var/lib/tftpboot',
         'server'      => '/usr/sbin/in.tftpd',
         'socket_type' => 'dgram',
         'cps'         => '100 2',
         'per_source'  => '11',
         'wait'        => 'yes',
         'subscribe'   => 'Anchor[ironic::install::end]',
        )
      end
      it 'should setup tftp xinetd service' do
        is_expected.to contain_xinetd__service('tftp').with(
         'bind' => '1.2.3.4',
        )
      end
    end

    context 'when excluding syslinux' do
      before :each do
        params.merge!(
          :syslinux_path => false,
        )
      end
      it 'should not contain package syslinux-tftpboot' do
        is_expected.not_to contain_package('syslinux-tftpboot')
      end
      it 'should not contain tftpboot syslinux file' do
        is_expected.not_to contain_file('/var/lib/ironic/tftpboot/pxelinux.0')
      end
    end

  end

  shared_examples_for 'ironic pxe in RedHat' do
    let :p do
      default_params.merge(params)
    end

    context 'when xinetd is disabled' do
      before :each do
        params.merge!(
          :tftp_use_xinetd => false,
        )
      end

      it 'should configure dnsmasq-tftp-server' do
        is_expected.to contain_file('/etc/ironic/dnsmasq-tftp-server.conf').with(
          'ensure' => 'present',
          'mode'   => '0644',
          'owner'  => 'root',
          'group'  => 'root',
        )
        is_expected.to contain_package('dnsmasq-tftp-server').with(
          'ensure' => 'present',
          'name'   => platform_params[:dnsmasq_tftp_package],
          'tag'    => ['openstack', 'ironic-ipxe', 'ironic-support-package'],
        )
        is_expected.to contain_service('dnsmasq-tftp-server').with(
          'ensure'    => 'running',
          'name'      => platform_params[:dnsmasq_tftp_service],
          'enable'    => true,
          'hasstatus' => true,
        )
      end

      it 'should not enable xinetd' do
        is_expected.to_not contain_package('tftp-server')
        is_expected.to_not contain_class('xinetd')
        is_expected.to_not contain_xinetd__service('tftp')
        is_expected.to contain_file('/tftpboot/map-file').with_ensure('absent')
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          {}
        when 'RedHat'
          { :dnsmasq_tftp_package => 'openstack-ironic-dnsmasq-tftp-server',
            :dnsmasq_tftp_service => 'openstack-ironic-dnsmasq-tftp-server' }
        end
      end

      # TODO(tkajinam): This should be refactored before we add support for
      #                 CentOS9, because xinetd is not available in CentOS9
      it_behaves_like 'ironic pxe'

      if facts[:osfamily] == 'RedHat'
        it_behaves_like 'ironic pxe in RedHat'
      end
    end
  end

end
