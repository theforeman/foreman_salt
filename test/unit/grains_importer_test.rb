require 'test_plugin_helper'

module ForemanSalt
  class GrainsImporterTest < ActiveSupport::TestCase
    setup do
      User.current = User.find_by_login 'admin'
      Setting[:create_new_host_when_facts_are_uploaded] = true

      # I don't even know, the plug-in successfully registers the importer
      # in development, and even on the Rails test console but not here
      # in the test itself...
      ::FactImporter.stubs(:importer_for).returns(ForemanSalt::FactImporter)

      grains = JSON.parse(File.read(File.join(Engine.root, 'test', 'unit', 'grains_centos.json')))
      @host  = grains['name']
      @facts = grains['facts']
    end

    test 'importing salt grains creates a host' do
      refute Host.find_by_name(@host)
      ::Host::Managed.import_host_and_facts @host, @facts
      assert Host.find_by_name(@host)
    end

    test 'grains are successfully imported for a host' do
      (host, _) = ::Host::Managed.import_host_and_facts @host, @facts
      assert_equal 'CentOS', host.facts_hash['operatingsystem']
    end

    test 'nested facts have valid parents' do
      (host, _) = ::Host::Managed.import_host_and_facts @host, @facts
      parent = ::FactName.find_by_name('cpu_flags')
      children = host.fact_values.with_fact_parent_id(parent)
      assert_not_empty children
      assert_empty children.map(&:fact_name).reject { |fact| fact.name =~ /\Acpu_flags#{FactName::SEPARATOR}[0-9]+/ }
    end
  end
end
