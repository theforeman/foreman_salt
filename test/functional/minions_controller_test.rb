require 'test_plugin_helper'

module ForemanSalt
  class MinionsControllerTest < ActionController::TestCase
    setup do
      User.current = User.anonymous_admin
      Setting::Salt.load_defaults
      Setting[:restrict_registered_smart_proxies] = true

      @proxy = FactoryBot.create(:smart_proxy, :with_salt_feature)
      Resolv.any_instance.stubs(:getnames).returns([@proxy.to_s])

      @hostgroup = FactoryBot.create(:hostgroup)
      @host = FactoryBot.create(:host, salt_environment: FactoryBot.create(:salt_environment), salt_proxy: @proxy)
      @host2 = FactoryBot.create(:host, hostgroup: @hostgroup, salt_environment: FactoryBot.create(:salt_environment), salt_proxy: @proxy)
      FactoryBot.create(:host_parameter, name: 'parameter1', value: 'different', host: @host)
    end

    test 'salt smart proxy should get salt external node' do
      get :node, params: { id: @host, format: 'yml' }
      assert_response :success

      res = YAML.safe_load(@response.body)
      assert_equal('different', res['parameters']['parameter1'])
    end

    test 'setting salt_namespace_pillars is considered' do
      Setting['salt_namespace_pillars'] = true

      get :node, params: { id: @host, format: 'yml' }
      assert_response :success

      res = YAML.safe_load(@response.body)
      assert_equal('different', res['parameters']['foreman']['parameter1'])
    end

    test 'salt variable is available' do
      var = FactoryBot.create(:salt_variable, override: true)
      var.salt_module.salt_environments << @host.salt_environment
      @host.salt_modules << var.salt_module

      get :node, params: { id: @host, format: 'yml' }
      assert_response :success

      res = YAML.safe_load(@response.body)
      assert_equal res['parameters'][var.key], var.value
    end

    test 'salt variable overrides host parameter' do
      var = FactoryBot.create(:salt_variable, key: 'parameter1', override: true)
      var.salt_module.salt_environments << @host.salt_environment
      @host.salt_modules << var.salt_module

      get :node, params: { id: @host, format: 'yml' }
      assert_response :success

      res = YAML.safe_load(@response.body)
      assert_equal res['parameters']['parameter1'], var.value
    end

    test 'salt variable matching host with host specific value' do
      var = FactoryBot.create(:salt_variable, key: 'parameter1', value: 'default', override: true)
      # rubocop:disable Lint/UselessAssignment
      value1 = LookupValue.create(lookup_key: var, match: 'os=debian', value: 'aaa')
      value2 = LookupValue.create(lookup_key: var, match: "fqdn=#{@host.fqdn}", value: 'myval')
      value3 = LookupValue.create(lookup_key: var, match: 'hostgroup=Unusual', value: 'bbbb')
      # rubocop:enable Lint/UselessAssignment

      var.salt_module.salt_environments << @host.salt_environment
      @host.salt_modules << var.salt_module

      get :node, params: { id: @host, format: 'yml' }
      assert_response :success

      res = YAML.safe_load(@response.body)
      assert_equal res['parameters']['parameter1'], value2.value
    end

    test 'salt variable matching host with hostgroup specific value' do
      var = FactoryBot.create(:salt_variable, key: 'parameter1', value: 'default', override: true)
      # rubocop:disable Lint/UselessAssignment
      value1 = LookupValue.create(lookup_key: var, match: 'os=debian', value: 'aaa')
      value2 = LookupValue.create(lookup_key: var, match: @hostgroup.lookup_value_matcher, value: 'bbbb')
      # rubocop:enable Lint/UselessAssignment

      var.salt_module.salt_environments << @host2.salt_environment
      @host2.salt_modules << var.salt_module

      get :node, params: { id: @host2, format: 'yml' }
      assert_response :success

      res = YAML.safe_load(@response.body)
      assert_equal res['parameters']['parameter1'], value2.value
    end

    test 'salt variable matching host with default value' do
      var = FactoryBot.create(:salt_variable, key: 'parameter1', value: 'default', override: true)
      # rubocop:disable Lint/UselessAssignment
      value1 = LookupValue.create(lookup_key: var, match: 'os=debian', value: 'aaa')
      value2 = LookupValue.create(lookup_key: var, match: "fqdn=#{@host.fqdn}", value: 'myval')
      value3 = LookupValue.create(lookup_key: var, match: 'hostgroup=Unusual', value: 'bbbb')
      # rubocop:enable Lint/UselessAssignment

      var.salt_module.salt_environments << @host2.salt_environment
      @host2.salt_modules << var.salt_module
      get :node, params: { id: @host2, format: 'yml' }
      assert_response :success

      res = YAML.safe_load(@response.body)
      assert_equal res['parameters']['parameter1'], var.value
    end
  end
end
