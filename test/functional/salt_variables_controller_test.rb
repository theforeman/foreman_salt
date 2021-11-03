# frozen_string_literal: true

require 'test_plugin_helper'
module ForemanSalt
  # functional tests for SaltVariablesController
  class SaltVariablesControllerTest < ActionController::TestCase
    setup do
      @model = FactoryBot.create(:salt_variable)
      @proxy = FactoryBot.create(:smart_proxy, :with_salt_feature)
    end

    basic_index_test 'salt_variables'
    basic_new_test
    basic_edit_test 'salt_variable'
    basic_pagination_per_page_test
    basic_pagination_rendered_test

    test 'should destroy variable' do
      assert_difference('SaltVariable.count', -1) do
        delete :destroy, params: { id: @model.id }, session: set_session_user
      end
      assert_redirected_to salt_variables_url
    end

    test 'should create salt variable' do
      params = { foreman_salt_salt_variable: { key: 'great name', salt_module_id: FactoryBot.create(:salt_module).id } }
      assert_difference('SaltVariable.count', 1) do
        post :create, params: params, session: set_session_user
      end
      assert_redirected_to salt_variables_url
    end
  end
end
