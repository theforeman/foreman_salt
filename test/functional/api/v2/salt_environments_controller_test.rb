require 'test_plugin_helper'

module ForemanSalt
  module Api
    module V2
      class SaltEnvironmentsControllerTest < ActionController::TestCase
        test 'should get index' do
          get :index
          assert_response :success
          assert_template 'api/v2/salt_environments/index'
        end

        test 'should show environment' do
          environment = ForemanSalt::SaltEnvironment.create(name: 'foo')
          get :show, params: { id: environment.id }
          assert_response :success
          assert_template 'api/v2/salt_environments/show'
        end

        test 'should create environment' do
          post :create, params: { environment: { name: 'unicorn' } }
          assert_response :success
          assert ForemanSalt::SaltEnvironment.find_by(name: 'unicorn')
          assert_template 'api/v2/salt_environments/create'
        end

        test 'should delete environment' do
          environment = ForemanSalt::SaltEnvironment.create(name: 'foo.bar.baz')
          assert_difference('ForemanSalt::SaltEnvironment.count', -1) do
            delete :destroy, params: { id: environment.id }
          end
          assert_response :success
        end
      end
    end
  end
end
