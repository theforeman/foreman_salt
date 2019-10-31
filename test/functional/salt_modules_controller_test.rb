# frozen_string_literal: true

require 'test_plugin_helper'
# functional tests for SaltModulesController
module ForemanSalt
  class SaltModulesControllerTest < ActionController::TestCase
    setup do
      @model = FactoryBot.create(:salt_module)
    end

    basic_index_test "salt_modules"
    basic_new_test
    basic_edit_test "salt_module"

    test 'should destroy module' do
      assert_difference('SaltModule.count', -1) do
        delete :destroy, :params => { :id => @model.id }, :session => set_session_user
      end
      assert_redirected_to salt_modules_url
    end
  end
end
