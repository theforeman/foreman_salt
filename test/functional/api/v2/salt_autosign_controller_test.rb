require 'test_plugin_helper'

class ::ForemanSalt::Api::V2::SaltAutosignControllerTest < ActionController::TestCase
  setup do
    @proxy = FactoryBot.create(:smart_proxy, :with_salt_feature)
    ProxyAPI::Salt.any_instance.stubs(:autosign_list).returns((%w(foo bar baz)))
  end

  test 'should get index' do
    get :index, :smart_proxy_id => @proxy.id
    assert_response :success
  end

  test 'should create autosign' do
    ProxyAPI::Salt.any_instance.expects(:autosign_create).once.returns(true)
    post :create, :smart_proxy_id => @proxy.id, :record => 'unicorn.example.com'
    assert_response :success
  end

  test 'should delete autosign' do
    ProxyAPI::Salt.any_instance.expects(:autosign_remove).once.returns(true)
    delete :destroy, :smart_proxy_id => @proxy.id, :record => 'unicorn.example.com'
    assert_response :success
  end
end
