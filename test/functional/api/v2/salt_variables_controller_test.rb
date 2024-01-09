# frozen_string_literal: true

require 'test_plugin_helper'

module ForemanSalt
  module Api
    module V2
      # Tests for the controller to CRUD Salt Variables
      class SaltVariablesControllerTest < ActionController::TestCase
        setup do
          @variable = FactoryBot.create(:salt_variable)
        end

        test 'should get index' do
          get :index, session: set_session_user
          response = JSON.parse(@response.body)

          assert_not_empty response['results']
          assert_response :success
        end

        test 'should destroy' do
          delete :destroy, params: { id: @variable.id }, session: set_session_user

          assert_response :ok
          assert_not SaltVariable.exists?(@variable.id)
        end

        test 'should create' do
          params = { key: 'test name', salt_state_id: FactoryBot.create(:salt_module).id }
          post :create, params: params, session: set_session_user

          assert_response :success
        end
      end
    end
  end
end
