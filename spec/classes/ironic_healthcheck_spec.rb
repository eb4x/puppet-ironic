require 'spec_helper'

describe 'ironic::healthcheck' do

  shared_examples_for 'ironic::healthcheck' do

    context 'with default parameters' do
      let :params do
        {}
      end

      it 'configures default values' do
        is_expected.to contain_ironic_config('healthcheck/enabled').with_value('<SERVICE DEFAULT>')

        is_expected.to contain_oslo__healthcheck('ironic_config').with(
          :detailed              => '<SERVICE DEFAULT>',
          :backends              => '<SERVICE DEFAULT>',
          :allowed_source_ranges => '<SERVICE DEFAULT>',
          :disable_by_file_path  => '<SERVICE DEFAULT>',
          :disable_by_file_paths => '<SERVICE DEFAULT>',
        )
      end
    end

    context 'with specific parameters' do
      let :params do
        {
          :enabled               => true,
          :detailed              => true,
          :backends              => ['disable_by_file'],
          :allowed_source_ranges => ['10.0.0.0/24', '10.0.1.0/24'],
          :disable_by_file_path  => '/etc/ironic/healthcheck/disabled',
          :disable_by_file_paths => ['8042:/etc/ironic/healthcheck/disabled'],
        }
      end

      it 'configures specified values' do
        is_expected.to contain_ironic_config('healthcheck/enabled').with_value(true)

        is_expected.to contain_oslo__healthcheck('ironic_config').with(
          :detailed              => true,
          :backends              => ['disable_by_file'],
          :allowed_source_ranges => ['10.0.0.0/24', '10.0.1.0/24'],
          :disable_by_file_path  => '/etc/ironic/healthcheck/disabled',
          :disable_by_file_paths => ['8042:/etc/ironic/healthcheck/disabled'],
        )
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'ironic::healthcheck'
    end
  end

end
