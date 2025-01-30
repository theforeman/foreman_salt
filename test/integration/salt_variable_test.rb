require 'test_plugin_helper'
require 'integration_test_helper'

module ForemanSalt
  class SaltVariableTest < IntegrationTestWithJavascript
    setup do
      User.current = users :admin
    end

    test 'index page' do
      FactoryBot.create_list :salt_variable, 5

      assert_index_page(salt_variables_path, 'Salt Variable', 'New Salt Variable')
    end

    test 'create new page' do
      state = FactoryBot.create :salt_module

      assert_new_button(salt_variables_path, 'New Salt Variable', new_salt_variable_path)
      fill_in 'foreman_salt_salt_variable_key', with: 'mykey'
      select2(state.name, from: 'foreman_salt_salt_variable_salt_module_id')

      assert_submit_button(salt_variables_path)
      assert page.has_link? 'mykey'
    end
  end
end
