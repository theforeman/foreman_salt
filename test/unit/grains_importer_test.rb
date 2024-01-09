require 'test_plugin_helper'

module ForemanSalt
  class GrainsImporterTest < ActiveSupport::TestCase
    include FactImporterIsolation
    allow_transactions_for_any_importer

    setup do
      disable_orchestration
      User.current = users :admin
      Setting[:create_new_host_when_facts_are_uploaded] = true

      Operatingsystem.where(name: 'CentOS', major: '6', minor: '5').delete_all

      grains = JSON.parse(File.read(File.join(Foreman::Application.root, 'test', 'static_fixtures', 'facts', 'grains_centos.json')))
      @imported_host = ::Host::Managed.import_host grains['name'], 'salt'
      ::HostFactImporter.new(@imported_host).import_facts grains['facts'].with_indifferent_access
    end

    test 'importing salt grains creates a host' do
      assert @imported_host
    end

    test 'grains are successfully imported for a host' do
      assert_equal 'CentOS', @imported_host.facts_hash['operatingsystem']
    end

    test 'nested facts have valid parents' do
      parent = ::FactName.find_by(name: 'cpu_flags')
      children = @imported_host.fact_values.with_fact_parent_id(parent)

      assert_not_empty children
      assert_empty children.map(&:fact_name).reject { |fact| fact.name =~ /\Acpu_flags#{FactName::SEPARATOR}[0-9]+/ }
    end

    # Parser
    test 'imported host has operating system' do
      assert_equal('CentOS 6.5', @imported_host.os.to_label)
    end

    test 'imported host operating system has deduced family' do
      assert_equal('Redhat', @imported_host.os.family)
    end

    test 'imported host has hardware model' do
      assert_equal('KVM', @imported_host.model.name)
    end

    test 'imported host has architecture' do
      assert_equal('x86_64', @imported_host.arch.name)
    end

    test 'imported host has primary ip' do
      assert_equal('10.7.13.141', @imported_host.ip)
    end

    test 'imported host has primary mac' do
      assert_equal('52:54:00:35:30:2a', @imported_host.mac)
    end

    test 'imported host has additional interface' do
      nic = @imported_host.interfaces.find_by(identifier: 'eth1')

      assert_equal('de:ad:be:ef:07:13', nic.mac)
      assert_equal('1.2.3.4', nic.ip)
    end
  end
end
