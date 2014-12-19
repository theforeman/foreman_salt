require 'test_plugin_helper'

module ForemanSalt
  class ReportImporterTest < ActiveSupport::TestCase
    setup do
      User.current = User.find_by_login 'admin'
      Setting[:create_new_host_when_facts_are_uploaded] = true

      @report = JSON.parse(File.read(File.join(Engine.root, 'test', 'unit', 'highstate.json')))

      @host = 'saltclient713.example.com'
    end

    test 'importing report creates a host' do
      refute Host.find_by_name(@host)
      ForemanSalt::ReportImporter.import(@report)
      assert Host.find_by_name(@host)
    end

    test 'importing report updates host status' do
      ForemanSalt::ReportImporter.import(@report)
      assert_equal Host.find_by_name(@host).host_status, 'Error'
    end

    test 'importing report has correct status' do
      ForemanSalt::ReportImporter.import(@report)
      status = Host.find_by_name(@host).reports.last.status
      assert_equal status['applied'], 9
      assert_equal status['failed'], 3
    end
  end
end
