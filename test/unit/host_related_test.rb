require 'test_plugin_helper'

class HostRelatedTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end

  test "host has a salt smart proxy" do
    host = FactoryGirl.create :host, :with_salt_proxy
    assert host.salt_proxy.features.map(&:name).include? 'Salt'
  end

  test "smart_proxy_ids returns salt smart proxy" do
    host = FactoryGirl.create :host, :with_salt_proxy
    assert host.smart_proxy_ids.include? host.salt_proxy_id
  end

  test "host group has a salt smart proxy" do
    hostgroup = FactoryGirl.create :hostgroup, :with_salt_proxy
    assert hostgroup.salt_proxy.features.map(&:name).include? 'Salt'
  end

  test "nested host group inherits salt smart proxy from parent" do
    parent = FactoryGirl.create :hostgroup, :with_salt_proxy
    child = FactoryGirl.create :hostgroup, :parent => parent
    assert_equal child.salt_proxy, parent.salt_proxy
  end

  test "child host group inherits salt proxy from child parent" do
    parent = FactoryGirl.create :hostgroup
    child_one = FactoryGirl.create :hostgroup, :with_salt_proxy, :parent => parent
    child_two = FactoryGirl.create :hostgroup, :parent => child_one
    assert_equal child_two.salt_proxy, child_one.salt_proxy
  end
end
