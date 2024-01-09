require 'test_plugin_helper'

module ForemanSalt
  class HostExtensionsTest < ActiveSupport::TestCase
    setup do
      User.current = users :admin
      @proxy = FactoryBot.create(:smart_proxy, :with_salt_feature)
    end

    test 'host has a salt smart proxy' do
      host = FactoryBot.create :host
      host.salt_proxy = @proxy

      assert host.salt_proxy.has_feature? 'Salt'
    end

    test 'smart_proxy_ids returns salt smart proxy' do
      host = FactoryBot.create :host
      host.salt_proxy = @proxy

      assert_includes host.smart_proxy_ids, host.salt_proxy_id
    end

    test 'host params includes salt_master' do
      host = FactoryBot.create :host
      host.salt_proxy = @proxy

      assert host.params.key? 'salt_master'
      assert_equal host.params['salt_master'], host.salt_master
    end

    test 'host inherits salt proxy from host group' do
      hostgroup = FactoryBot.create :hostgroup
      hostgroup.salt_proxy = @proxy
      host = FactoryBot.create :host, hostgroup: hostgroup
      host.set_hostgroup_defaults

      assert_equal host.salt_proxy, hostgroup.salt_proxy
    end

    test 'host does not accept salt modules outside its environment' do
      hosts_environment = FactoryBot.create :salt_environment
      other_environment = FactoryBot.create :salt_environment

      state = FactoryBot.create :salt_module
      other_environment.salt_modules << state

      host = FactoryBot.create :host, salt_environment: hosts_environment
      host.salt_proxy = @proxy
      host.salt_modules = [state]

      assert_not host.save
      assert_includes host.errors.full_messages, 'Salt states must be in the environment of the host'
    end

    test '#configuration? considers salt' do
      host = FactoryBot.build(:host)

      assert_not host.configuration?
      host.salt_proxy = @proxy

      assert_predicate host, :configuration?
    end

    context 'autosign handling' do
      before do
        @host = FactoryBot.create(:host, :managed)
        @host.salt_proxy = @proxy
        stub_request(:post, "#{@proxy.url}/salt/autosign_key/asdfasdfasfasdf")
          .to_return(status: 200, body: '', headers: {})
        stub_request(:delete, "#{@proxy.url}/salt/key/#{@host.name}")
          .to_return(status: 200, body: '', headers: {})
      end

      test 'host autosign is created when host is built' do
        autosign_key = 'asdfasdfasfasdf'
        @host.expects(:generate_provisioning_key).returns(autosign_key)
        @host.build = true

        assert @host.save!
        @host.clear_host_parameters_cache!

        assert_equal autosign_key, @host.salt_autosign_key
      end
    end

    context 'function derive_salt_grains' do
      before do
        @host = FactoryBot.create(:host, :managed)
        @host.salt_proxy = @proxy
      end

      test 'host returns empty hash when deriving salt grains with default autosign' do
        expected_hash = {}

        assert_equal expected_hash, @host.instance_eval { derive_salt_grains }
      end

      test 'host returns autosign when deriving salt grains' do
        autosign_key = 'asdfasdfasfasdf'
        expected_hash = { @host.autosign_grain_name => autosign_key }
        @host.salt_autosign_key = autosign_key

        assert_equal expected_hash, @host.instance_eval { derive_salt_grains(use_autosign: true) }
      end

      test 'host returns empty hash when deriving salt grains without any given' do
        expected_hash = {}

        assert_equal expected_hash, @host.instance_eval { derive_salt_grains(use_autosign: true) }
      end

      test 'host returns empty hash when deriving salt grains without autosign' do
        expected_hash = {}

        assert_equal expected_hash, @host.instance_eval { derive_salt_grains(use_autosign: false) }
      end

      test 'host returns host param grains when deriving salt grains' do
        expected_hash = { "Some key": 'Some value', "Another key": 'An extraordinary value' }
        @host.host_params[@host.host_params_grains_name] = expected_hash

        assert_equal expected_hash, @host.instance_eval { derive_salt_grains(use_autosign: false) }
      end

      test 'host returns only host param grains when deriving salt grains' do
        expected_hash = { "Some key": 'Some value', "Another key": 'An extraordinary value' }
        @host.host_params[@host.host_params_grains_name] = expected_hash

        assert_equal expected_hash, @host.instance_eval { derive_salt_grains(use_autosign: true) }
      end

      test 'host returns host param grains plus autosign when deriving salt grains' do
        autosign_key = 'asdfasdfasfasdf'
        host_param_grains = { "Some key": 'Some value',
                              "Another key": 'An extraordinary value' }
        expected_hash = host_param_grains.merge(@host.autosign_grain_name => autosign_key)
        @host.salt_autosign_key = autosign_key
        @host.host_params[@host.host_params_grains_name] = host_param_grains

        assert_equal expected_hash, @host.instance_eval { derive_salt_grains(use_autosign: true) }
      end
    end
  end
end
