require 'test_plugin_helper'

module ForemanSalt
  module Api
    module V2
      class SaltKeysControllerTest < ActionController::TestCase
        setup do
          @proxy = FactoryBot.create(:smart_proxy, :with_salt_feature)

          ProxyAPI::Salt.any_instance.stubs(:key_list).returns('saltstack.example.com' => { 'state' => 'unaccepted',
                                                                                            'fingerprint' => '98:c2:63:c1:57:59:bc:bd:f1:ef:5a:38:b2:e9:71:c0' })
        end

        test 'should get index' do
          get :index, params: { smart_proxy_id: @proxy.id }

          assert_response :success
        end

        test 'should update keys' do
          ProxyAPI::Salt.any_instance.expects(:key_accept).once.returns(true)
          put :update, params: { smart_proxy_id: @proxy.id, name: 'saltstack.example.com', state: 'accepted' }

          assert_response :success
        end

        test 'should delete keys' do
          ProxyAPI::Salt.any_instance.expects(:key_delete).once.returns(true)
          delete :destroy, params: { smart_proxy_id: @proxy.id, name: 'saltstack.example.com' }

          assert_response :success
        end
      end
    end
  end
end
