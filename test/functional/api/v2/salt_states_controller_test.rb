require 'test_plugin_helper'

module ForemanSalt
  class Api::V2::SaltStatesControllerTest < ActionController::TestCase
    test 'should get index' do
      get :index, {}
      assert_response :success
      assert_template 'api/v2/salt_states/index'
    end

    test 'should show state' do
      state = ForemanSalt::SaltModule.create(:name => 'foo.bar.baz')
      get :show, :id => state.id
      assert_response :success
      assert_template 'api/v2/salt_states/show'
    end

    test 'should create state' do
      post :create, :state => { :name => 'unicorn' }
      assert_response :success
      assert ForemanSalt::SaltModule.find_by_name('unicorn')
      assert_template 'api/v2/salt_states/create'
    end

    test 'should delete state' do
      state = ForemanSalt::SaltModule.create(:name => 'foo.bar.baz')
      assert_difference('ForemanSalt::SaltModule.count', -1) do
        delete :destroy, :id => state.id
      end
      assert_response :success
    end
  end
end
