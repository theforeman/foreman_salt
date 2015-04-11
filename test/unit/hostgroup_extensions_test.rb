require 'test_plugin_helper'

module ForemanSalt
  class HostgroupExtensionsTest < ActiveSupport::TestCase
    setup do
      User.current = User.find_by_login 'admin'
    end

    test 'host group has a salt smart proxy' do
      hostgroup = FactoryGirl.create :hostgroup, :with_salt_proxy
      assert hostgroup.salt_proxy.features.map(&:name).include? 'Salt'
    end

    test 'nested host group inherits salt modules from parent' do
      parent = FactoryGirl.create :hostgroup, :with_salt_modules
      child = FactoryGirl.create :hostgroup, :parent => parent
      assert_equal [], parent.all_salt_modules - child.all_salt_modules
    end

    test 'child host group inherits salt proxy from child parent' do
      parent = FactoryGirl.create :hostgroup
      child_one = FactoryGirl.create :hostgroup, :with_salt_proxy, :parent => parent
      child_two = FactoryGirl.create :hostgroup, :parent => child_one
      assert_equal child_two.salt_proxy, child_one.salt_proxy
    end

    test 'child and parent salt modules are combined' do
      parent = FactoryGirl.create :hostgroup, :with_salt_modules
      child = FactoryGirl.create :hostgroup, :with_salt_modules, :parent => parent
      assert_equal 10, (child.salt_modules - parent.salt_modules).length
    end

    test 'second child inherits from parent' do
      parent = FactoryGirl.create :hostgroup, :with_salt_modules
      child_one = FactoryGirl.create :hostgroup, :parent => parent
      child_two = FactoryGirl.create :hostgroup, :parent => child_one
      assert_equal [], parent.all_salt_modules - child_two.all_salt_modules
    end
  end
end
