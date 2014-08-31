require 'test_plugin_helper'

module ForemanSalt
  class SaltModuleTest < ActionDispatch::IntegrationTest

    test "index page" do
      FactoryGirl.create_list :salt_module, 50
      assert_index_page(salt_modules_path, "Salt modules", "New Salt module")
    end

    test "create new page" do
      assert_new_button(salt_modules_path, "New Salt module", new_salt_module_path)
      fill_in "foreman_salt_salt_module_name", :with => "common"
      assert_submit_button(salt_modules_path)
      assert page.has_link? 'common'
    end

    test "edit page" do
      salt_module = FactoryGirl.create :salt_module
      visit salt_modules_path
      click_link salt_module.name 
      fill_in "foreman_salt_salt_module_name", :with => "some_other_name"
      assert_submit_button(salt_modules_path)
      assert page.has_link? 'some_other_name'
    end
  end
end
