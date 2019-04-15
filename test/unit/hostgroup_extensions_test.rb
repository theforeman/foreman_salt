require 'test_plugin_helper'

module ForemanSalt
  class HostgroupExtensionsTest < ActiveSupport::TestCase
    setup do
      User.current = users :admin
      @proxy = FactoryBot.create(:smart_proxy, :with_salt_feature)
    end

    test 'host group has a salt smart proxy' do
      hostgroup = FactoryBot.create :hostgroup
      hostgroup.salt_proxy = @proxy
      assert hostgroup.salt_proxy.features.map(&:name).include? 'Salt'
    end

    test 'nested host group inherits salt modules from parent' do
      parent = FactoryBot.create :hostgroup, :with_salt_modules
      child = FactoryBot.create :hostgroup, :parent => parent
      assert_equal [], parent.all_salt_modules - child.all_salt_modules
    end

    test 'child host group inherits salt proxy from child parent' do
      parent = FactoryBot.create :hostgroup
      child_one = FactoryBot.create :hostgroup, :parent => parent
      child_one.salt_proxy = @proxy
      child_one.reload
      child_two = FactoryBot.create :hostgroup, :parent => child_one
      assert_equal child_two.salt_proxy, child_one.salt_proxy
    end

    test 'child host group inherits salt environment from child parent' do
      environment = FactoryBot.create :salt_environment
      parent = FactoryBot.create :hostgroup
      child_one = FactoryBot.create :hostgroup, :parent => parent
      child_one.salt_environment = environment
      child_one.reload
      child_two = FactoryBot.create :hostgroup, :parent => child_one
      assert_equal child_two.salt_environment, child_one.salt_environment
    end

    test 'child and parent salt modules are combined' do
      environment = FactoryBot.create :salt_environment
      parent = FactoryBot.create :hostgroup, :with_salt_modules, :salt_environment => environment
      child = FactoryBot.create :hostgroup, :with_salt_modules, :salt_environment => environment, :parent => parent

      total = parent.salt_modules.count + child.salt_modules.count
      assert_equal total, child.all_salt_modules.count
    end

    test 'child doesnt get modules from outside its environment' do
      parent = FactoryBot.create :hostgroup, :with_salt_modules
      child = FactoryBot.create :hostgroup, :with_salt_modules, :parent => parent
      assert_equal child.salt_modules.count, child.all_salt_modules.count
    end

    test 'inheritance when only parent has modules' do
      parent = FactoryBot.create :hostgroup, :with_salt_modules
      child_one = FactoryBot.create :hostgroup, :parent => parent
      child_two = FactoryBot.create :hostgroup, :parent => child_one
      assert_empty parent.all_salt_modules - child_two.all_salt_modules
    end

    test 'inheritance when no parents have modules' do
      parent = FactoryBot.create :hostgroup
      child_one = FactoryBot.create :hostgroup, :parent => parent
      child_two = FactoryBot.create :hostgroup, :with_salt_modules, :parent => child_one
      assert child_two.all_salt_modules.any?
    end
  end
end
