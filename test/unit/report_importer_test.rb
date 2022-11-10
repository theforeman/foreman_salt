require 'test_plugin_helper'

module ForemanSalt
  class ReportImporterTest < ActiveSupport::TestCase
    setup do
      User.current = users :admin
      Setting[:create_new_host_when_facts_are_uploaded] = true

      @report = JSON.parse(File.read(File.join(Engine.root, 'test', 'unit', 'highstate.json')))
      @report_pchanges = JSON.parse(File.read(File.join(Engine.root, 'test', 'unit', 'highstate_pchanges.json')))
      @report_unhandled = JSON.parse(File.read(File.join(Engine.root, 'test', 'unit', 'highstate_unhandled.json')))

      @host = 'saltclient713.example.com'
    end

    test 'importing report creates a host' do
      assert_not Host.find_by(name: @host)
      ForemanSalt::ReportImporter.import(@report)
      assert Host.find_by(name: @host)
    end

    test 'importing report updates host status' do
      HostStatus::ConfigurationStatus.any_instance.stubs(:relevant?).returns(true)
      ForemanSalt::ReportImporter.import(@report)
      assert Host.find_by(name: @host).get_status(HostStatus::ConfigurationStatus).error?
    end

    test 'importing report has correct status' do
      ForemanSalt::ReportImporter.import(@report)
      status = Host.find_by(name: @host).reports.last.status
      assert_equal(9, status['applied'])
      assert_equal(3, status['failed'])
    end

    test 'report has salt origin and expected content' do
      ForemanSalt::ReportImporter.import(@report)
      report = Host.find_by(name: @host).reports.last
      assert_equal 'Salt', report.origin
      assert_equal 'pkg_|-postfix_|-postfix_|-installed', report.logs.first.source.value
      assert_equal 'Package postfix is already installed.', report.logs.first.message.value
    end

    test 'report with pchanges has salt origin and expected content' do
      ForemanSalt::ReportImporter.import(@report_pchanges)
      report = Host.find_by(name: @host).reports.last
      status = report.status
      assert_equal 'Salt', report.origin
      assert_equal 'file_|-/etc/motd_|-/etc/motd_|-managed', report.logs.first.source.value
      assert_equal(1, status['pending'])
    end

    test 'import returns Array of reports including host and its name' do
      reports = ForemanSalt::ReportImporter.import(@report)
      assert_kind_of Array, reports
      first = reports.first
      assert_equal 'Salt', first.origin
      assert_equal @host, first.host.name
    end

    test 'importing report with unhandled highstate' do
      HostStatus::ConfigurationStatus.any_instance.stubs(:relevant?).returns(true)
      ForemanSalt::ReportImporter.import(@report_unhandled)
      assert Host.find_by(name: @host).get_status(HostStatus::ConfigurationStatus).error?
    end
  end
end
