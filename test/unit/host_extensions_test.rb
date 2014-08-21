require 'test_plugin_helper'

class HostExtensionsTest < ActiveSupport::TestCase
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

  test "host params includes salt_master" do
    host = FactoryGirl.create :host, :with_salt_proxy
    assert host.params.key? "salt_master"
    assert_equal host.params["salt_master"], host.salt_master
  end

  test "host inherits salt proxy from host group" do
    hostgroup = FactoryGirl.create :hostgroup, :with_salt_proxy
    host = FactoryGirl.create :host, :hostgroup => hostgroup
    host.set_hostgroup_defaults
    assert_equal host.salt_proxy, hostgroup.salt_proxy
  end
end
