require 'test_plugin_helper'
require 'integration_test_helper'

module ForemanSalt
  class SaltKeysTest < ActionDispatch::IntegrationTest
    setup do
      @proxy = FactoryBot.create :smart_proxy, :with_salt_feature

      ::ProxyAPI::Salt.any_instance.stubs(:autosign_list).returns(
        ['foo.example.com']
      )
    end

    test 'smart proxy page has autosign link' do
      assert_row_button(smart_proxies_path, @proxy.name, 'Salt Autosign', true)
    end

    test 'smart proxy details has autosign link' do
      visit smart_proxy_path(@proxy)
      assert page.has_link? "Salt Autosign"
      click_link "Salt Autosign"
      assert page.has_content?("Autosign entries for #{@proxy.hostname}"), 'Page title does not appear'
    end

    test 'index page' do
      visit smart_proxy_salt_autosign_index_path(:smart_proxy_id => @proxy.id)
      assert find_link('Keys').visible?, 'Keys is not visible'
      assert has_content?("Autosign entries for #{@proxy.hostname}"), 'Page title does not appear'
      assert has_content?('Displaying'), 'Pagination "Display ..." does not appear'
    end

    test 'has list of autosign' do
      visit smart_proxy_salt_autosign_index_path(:smart_proxy_id => @proxy.id)
      assert has_content?('foo.example.com'), 'Missing autosign entry on index page'
    end
  end
end
