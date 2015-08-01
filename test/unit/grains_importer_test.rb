require 'test_plugin_helper'

module ForemanSalt
  class GrainsImporterTest < ActiveSupport::TestCase
    setup do
      User.current = User.find_by_login 'admin'
      Setting[:create_new_host_when_facts_are_uploaded] = true

      Operatingsystem.where(:name => 'CentOS', :major => '6', :minor => '5').delete_all

      @grains = JSON.parse(File.read(File.join(Engine.root, 'test', 'unit', 'grains_centos.json')))
      host  = @grains['name']
      facts = HashWithIndifferentAccess.new(@grains['facts'])

      (@imported_host, _) = ::Host::Managed.import_host_and_facts host, facts
    end

    test 'importing salt grains creates a host' do
      assert @imported_host
    end

    test 'grains are successfully imported for a host' do
      assert_equal 'CentOS', @imported_host.facts_hash['operatingsystem']
    end

    test 'nested facts have valid parents' do
      parent = ::FactName.find_by_name('cpu_flags')
      children = @imported_host.fact_values.with_fact_parent_id(parent)
      assert_not_empty children
      assert_empty children.map(&:fact_name).reject { |fact| fact.name =~ /\Acpu_flags#{FactName::SEPARATOR}[0-9]+/ }
    end

    context 'parser' do
      test 'imported host has operating system' do
        assert_equal @imported_host.os.to_label, 'CentOS 6.5'
      end

      test 'imported host operating system has deduced family' do
        assert_equal @imported_host.os.family, 'Redhat'
      end

      test 'imported host has hardware model' do
        assert_equal @imported_host.model.name, 'KVM'
      end

      test 'imported host has architecture' do
        assert_equal @imported_host.arch.name, 'x86_64'
      end

      test 'imported host has primary ip' do
        assert_equal @imported_host.ip, '10.7.13.141'
      end

      test 'imported host has primary mac' do
        assert_equal @imported_host.mac, '52:54:00:35:30:2a'
      end

      test 'imported host has additional interface' do
        nic = @imported_host.interfaces.find_by_identifier('eth1')
        assert_equal nic.mac, 'de:ad:be:ef:07:13'
        assert_equal nic.ip, '1.2.3.4'
      end

      test 'parser ignores bad ip' do
        facts = HashWithIndifferentAccess.new(@grains['facts'])
        facts['fqdn_ip4::0'] = 'bad_value'
        (host, _) = ::Host::Managed.import_host_and_facts 'bad.example.com', facts
        assert host.ip.blank?
      end

      test 'parser ignores bad mac' do
        facts = HashWithIndifferentAccess.new(@grains['facts'])
        facts['hwaddr_interfaces::eth0'] = 'bad_value'
        (host, _) = ::Host::Managed.import_host_and_facts 'bad.example.com', facts
        assert host.mac.blank?
      end
    end
  end
end
