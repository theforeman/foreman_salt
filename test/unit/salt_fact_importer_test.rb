require 'test_plugin_helper'

module ForemanSalt
  class SaltFactImpoterTest < ActiveSupport::TestCase
    def setup
      @host = FactoryBot.build(:host)
    end

    test 'should have fact set' do
      importer = FactImporter.new(@host, 'a' => 'b')
      assert_equal({ 'a' => 'b' }, importer.send(:facts))
    end

    test 'should have Salt as origin' do
      importer = FactImporter.new(@host, 'a' => 'b')
      importer.stubs(:ensure_no_active_transaction).returns(true)
      importer.import!
      imported_fact = FactName.find_by_name('a')
      assert_equal 'a', imported_fact.name
      assert_equal 'foreman_salt/Salt', imported_fact.origin
    end
  end
end
