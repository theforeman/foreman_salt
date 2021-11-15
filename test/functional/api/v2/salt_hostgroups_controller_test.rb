require 'test_plugin_helper'

module ForemanSalt
  module Api
    module V2
      class SaltHostgroupsControllerTest < ActionController::TestCase
        setup do
          @proxy = FactoryBot.create(:smart_proxy, :with_salt_feature)
          @env = ForemanSalt::SaltEnvironment.create(name: 'basement')
          @state = ForemanSalt::SaltModule.create(name: 'motd')
        end

        test 'should show host group' do
          hostgroup = FactoryBot.create(:hostgroup)
          get :show, params: { id: hostgroup.id }

          assert_response :success
          assert_template 'foreman_salt/api/v2/salt_hostgroups/show'
        end

        test 'should set proxy' do
          hostgroup = FactoryBot.create(:hostgroup)
          put :update, params: { id: hostgroup.id, hostgroup: { salt_proxy_id: @proxy.id } }
          response_json = ActiveSupport::JSON.decode(response.body)
          # remove protocol and port
          clean_url = @proxy.url[8..-6]

          assert_response :success
          assert_template 'foreman_salt/api/v2/salt_hostgroups/update'
          assert_equal clean_url, response_json['salt_master']
        end

        test 'should not find proxy' do
          hostgroup = FactoryBot.create(:hostgroup)
          put :update, params: { id: hostgroup.id, hostgroup: { salt_proxy_id: -2 } }

          assert_response 422 # unprocessable entity
        end

        test 'should set environment' do
          hostgroup = FactoryBot.create(:hostgroup)
          put :update, params: { id: hostgroup.id, hostgroup: { salt_environment_id: @env.id } }
          response_json = ActiveSupport::JSON.decode(response.body)

          assert_response :success
          assert_template 'foreman_salt/api/v2/salt_hostgroups/update'
          assert_equal @env.name, response_json['salt_environment']
        end

        test 'should not find environment' do
          hostgroup = FactoryBot.create(:hostgroup)
          put :update, params: { id: hostgroup.id, hostgroup: { salt_environment_id: -12 } }

          assert_response 422 # unprocessable entity
        end

        test 'should set states' do
          hostgroup = FactoryBot.create(:hostgroup)
          put :update, params: { id: hostgroup.id, hostgroup: { salt_state_ids: [@state.id] } }
          response_json = ActiveSupport::JSON.decode(response.body)

          assert_response :success
          assert_template 'foreman_salt/api/v2/salt_hostgroups/update'
          assert_equal @state.name, response_json['salt_states'][0]['name']
        end

        test 'should not find states' do
          hostgroup = FactoryBot.create(:hostgroup)
          put :update, params: { id: hostgroup.id, hostgroup: { salt_state_ids: [-5] } }

          assert_response 422 # unprocessable entity
        end
      end
    end
  end
end
