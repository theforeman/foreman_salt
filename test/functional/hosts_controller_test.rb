require 'pry'
require 'test_plugin_helper'

class HostsControllerTest < ActionController::TestCase
  test 'salt smart proxy should get salt external node' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false


    proxy = FactoryGirl.create :smart_proxy, :with_salt_feature
    Resolv.any_instance.stubs(:getnames).returns([proxy.to_s])

    host = FactoryGirl.create :host
    #binding.pry
    get :salt_external_node, {:name => host.name, :format => "yml"}
    assert_response :success
  end
end
