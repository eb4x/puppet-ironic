require 'spec_helper'

describe 'ironic::inspector::db::postgresql' do

  shared_examples_for 'ironic::inspector::db::postgresql' do
    let :req_params do
      { :password => 'ironicpass' }
    end

    let :pre_condition do
      'include postgresql::server'
    end

    context 'with only required parameters' do
      let :params do
        req_params
      end

      it { is_expected.to contain_openstacklib__db__postgresql('ironic-inspector').with(
        :user       => 'ironic-inspector',
        :password   => 'ironicpass',
        :dbname     => 'ironic-inspector',
        :encoding   => nil,
        :privileges => 'ALL',
      )}
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      # TODO(tkajinam): Remove this once puppet-postgresql supports CentOS 9
      unless facts[:osfamily] == 'RedHat' and facts[:operatingsystemmajrelease].to_i >= 9
        it_behaves_like 'ironic::inspector::db::postgresql'
      end
    end
  end

end
