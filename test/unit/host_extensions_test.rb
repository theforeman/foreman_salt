require 'test_plugin_helper'

module ForemanSalt
  class HostExtensionsTest < ActiveSupport::TestCase
    setup do
      User.current = User.find_by_login 'admin'
    end

    test 'host has a salt smart proxy' do
      host = FactoryBot.create :host, :with_salt_proxy
      assert host.salt_proxy.has_feature? 'Salt'
    end

    test 'smart_proxy_ids returns salt smart proxy' do
      host = FactoryBot.create :host, :with_salt_proxy
      assert host.smart_proxy_ids.include? host.salt_proxy_id
    end

    test 'host params includes salt_master' do
      host = FactoryBot.create :host, :with_salt_proxy
      assert host.params.key? 'salt_master'
      assert_equal host.params['salt_master'], host.salt_master
    end

    test 'host inherits salt proxy from host group' do
      hostgroup = FactoryBot.create :hostgroup, :with_salt_proxy
      host = FactoryBot.create :host, :hostgroup => hostgroup
      host.set_hostgroup_defaults
      assert_equal host.salt_proxy, hostgroup.salt_proxy
    end

    test 'host does not accept salt modules outside its environment' do
      hosts_environment = FactoryBot.create :salt_environment
      other_environment = FactoryBot.create :salt_environment

      state = FactoryBot.create :salt_module
      other_environment.salt_modules << state

      host = FactoryBot.create :host, :with_salt_proxy, :salt_environment => hosts_environment
      host.salt_modules = [state]

      refute host.save
      assert host.errors.full_messages.include? 'Salt states must be in the environment of the host'
    end

    test '#configuration? considers salt' do
      host = FactoryBot.build(:host)
      proxy = FactoryBot.build(:smart_proxy)

      refute host.configuration?
      host.salt_proxy = proxy
      assert host.configuration?
    end

    context 'key handling' do
      before do
        @host = FactoryBot.create(:host, :with_salt_proxy, :managed, :build => true)
        @key_stub = stub("key")
        ForemanSalt::SmartProxies::SaltKeys.expects(:find).at_least_once.with(@host.salt_proxy, @host.fqdn).returns(@key_stub)
      end

      test 'host key is accepted when host is built' do
        @key_stub.expects(:accept).at_least_once.returns(true)
        assert @host.built
        @host.run_callbacks(:commit) # callbacks don't run with Foreman's transactional fixtures
      end

      test 'host key is deleted when host is removed' do
        @key_stub.expects(:delete).returns(true)
        assert @host.destroy
      end
    end
  end
end
