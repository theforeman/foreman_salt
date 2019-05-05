require 'test_plugin_helper'

module ForemanSalt
  class ReportImporterTest < ActiveSupport::TestCase
    setup do
      User.current = users :admin
      Setting[:create_new_host_when_facts_are_uploaded] = true

      @report = JSON.parse(File.read(File.join(Engine.root, 'test', 'unit', 'highstate.json')))

      @host = 'saltclient713.example.com'
    end

    test 'importing report creates a host' do
      assert_not Host.find_by_name(@host)
      ForemanSalt::ReportImporter.import(@report)
      assert Host.find_by_name(@host)
    end

    test 'importing report updates host status' do
      HostStatus::ConfigurationStatus.any_instance.stubs(:relevant?).returns(true)
      ForemanSalt::ReportImporter.import(@report)
      assert Host.find_by_name(@host).get_status(HostStatus::ConfigurationStatus).error?
    end

    test 'importing report has correct status' do
      ForemanSalt::ReportImporter.import(@report)
      status = Host.find_by_name(@host).reports.last.status
      assert_equal status['applied'], 9
      assert_equal status['failed'], 3
    end

    test 'report has salt origin and expected content' do
      ForemanSalt::ReportImporter.import(@report)
      report = Host.find_by_name(@host).reports.last
      assert_equal 'Salt', report.origin
      assert_equal 'pkg_|-postfix_|-postfix_|-installed', report.logs.first.source.value
      assert_equal 'Package postfix is already installed.', report.logs.first.message.value
    end
  end
end
