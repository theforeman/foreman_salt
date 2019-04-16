require 'test_plugin_helper'

module ForemanSalt
  class MinionsControllerTest < ActionController::TestCase
    test 'salt smart proxy should get salt external node' do
      User.current = User.anonymous_admin
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = false

      proxy = FactoryBot.create :smart_proxy, :with_salt_feature
      Resolv.any_instance.stubs(:getnames).returns([proxy.to_s])

      host = FactoryBot.create :host
      get :node, params: { :id => host, :format => 'yml' }
      assert_response :success
    end
  end
end
