require 'spec_helper_acceptance'

describe 'puppet-openstack_health::api manifest', :if => ['debian', 'ubuntu'].include?(os[:family]) do
  def pp_path
    base_path = File.dirname(__FILE__)
    File.join(base_path, 'fixtures')
  end

  def frontend_puppet_module
    module_path = File.join(pp_path, 'frontend.pp')
    File.read(module_path)
  end

  it 'should work with no errors' do
    apply_manifest(frontend_puppet_module, catch_failures: true)
  end

  describe 'required packages' do
    describe 'os packages' do
      required_packages = [
        package('apache2'),
        package('nodejs'),
      ]

      required_packages.each do |package|
        describe package do
          it { should be_installed }
        end
      end
    end

    describe 'npm packages' do
      required_packages = [
        package('node-gyp'),
        package('gulp'),
      ]

      required_packages.each do |package|
        describe package do
          it { should be_installed.by('npm') }
        end
      end
    end
  end

  describe 'required files' do
    describe file('/opt/openstack-health') do
      it { should be_directory }
      it { should be_owned_by 'openstack_health' }
      it { should be_grouped_into 'openstack_health' }
    end
  end

  describe 'required services' do
    describe 'ports are open and services are reachable' do
      describe port(80) do
        it { should be_listening }
      end

      describe command('curl http://localhost --verbose') do
        its(:stdout) { should contain('OpenStack Health') }
      end
    end
  end
end
