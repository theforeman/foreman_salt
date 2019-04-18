require 'test_plugin_helper'

module ForemanSalt
  class SaltFactsParserTest < ActiveSupport::TestCase
    attr_reader :importer

    def setup
      grains = JSON.parse(File.read(File.join(Engine.root, 'test', 'unit', 'grains_centos.json')))
      @importer = FactParser.new grains["facts"]
      User.current = users :admin
    end

    test "should return list of interfaces" do
      assert importer.interfaces.present?
      assert_not_nil importer.suggested_primary_interface(FactoryBot.build(:host))
      assert importer.interfaces.key?(importer.suggested_primary_interface(FactoryBot.build(:host)).first)
    end

    test "should set operatingsystem correctly" do
      os = importer.operatingsystem
      assert os.present?
      assert_equal 'CentOS', os.name
      assert_equal '6', os.major
      assert_equal '5', os.minor
      assert_equal 'CentOS 6.5', os.title
    end

    test "should set domain correctly" do
      domain = importer.domain
      assert domain.present?
      assert_equal 'example.com', domain.name
    end

    test "should set ip correctly" do
      assert_equal '10.7.13.141', importer.ip
    end

    test "should set primary_interface correctly" do
      assert_equal 'eth0', importer.primary_interface
    end

    test "should set mac correctly" do
      assert_equal '52:54:00:35:30:2a', importer.mac
    end
  end
end
