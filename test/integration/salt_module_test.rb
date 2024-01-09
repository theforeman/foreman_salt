require 'test_plugin_helper'
require 'integration_test_helper'

module ForemanSalt
  class SaltModuleTest < IntegrationTestWithJavascript
    setup do
      User.current = users :admin

      states = %w[state1 state2 state3 state4]
      state_list = { 'env1' => states, 'env2' => states }

      ProxyAPI::Salt.any_instance.stubs(:states_list).returns(state_list)
    end

    test 'index page' do
      FactoryBot.create_list :salt_module, 5

      assert_index_page(salt_modules_path, 'Salt State', 'New Salt State')
    end

    test 'create new page' do
      assert_new_button(salt_modules_path, 'New Salt State', new_salt_module_path)
      fill_in 'foreman_salt_salt_module_name', with: 'common'

      assert_submit_button(salt_modules_path)
      assert page.has_link? 'common'
    end

    test 'edit page' do
      salt_module = FactoryBot.create :salt_module
      visit salt_modules_path
      click_link salt_module.name
      fill_in :foreman_salt_salt_module_name, with: 'some_other_name'

      assert_submit_button(salt_modules_path)
      assert page.has_link? 'some_other_name'
    end

    test 'import states' do
      proxy = FactoryBot.create :smart_proxy, :with_salt_feature
      state = FactoryBot.create :salt_module, salt_environments: [FactoryBot.create(:salt_environment)]

      visit salt_modules_path
      click_link "Import from #{proxy.name}"

      assert page.has_selector?('td', text: 'env1'), 'Could not find env1 on importer page'
      assert page.has_selector?('td', text: 'Add'), 'Could not find env1 on importer page'
      assert page.has_selector?('td', text: 'state1, state2, state3, and state4'), 'Could not find states on importer page'

      assert page.has_selector?('td', text: 'Remove'), 'Could not find remove on importer page'
      assert page.has_selector?('td', text: state.name), 'Could not find state to remove'

      all('input.state_check').each { |checkbox| check(checkbox[:id]) }

      click_button 'Update'

      assert page.has_link? 'state1'
    end
  end
end
