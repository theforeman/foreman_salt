require 'test_plugin_helper'
require 'integration_test_helper'

module ForemanSalt
  class SaltKeysTest < ActionDispatch::IntegrationTest
    setup do
      @proxy = FactoryBot.create :smart_proxy, :with_salt_feature

      ProxyAPI::Salt.any_instance.stubs(:key_list).returns(
        'saltstack.example.com' => { 'state' => 'accepted', 'fingerprint' => '98:c2:63:c1:57:59:bc:bd:f1:ef:5a:38:b2:e9:71:c0' },
        'saltclient01.example.com' => { 'state' => 'unaccepted', 'fingerprint' => '98:c2:63:c1:57:59:bc:bd:f1:ef:5a:38:b2:e9:71:c1' },
        'saltclient02.example.com' => { 'state' => 'unaccepted', 'fingerprint' => '98:c2:63:c1:57:59:bc:bd:f1:ef:5a:38:b2:e9:71:c2' },
        'saltclient03.example.com' => { 'state' => 'rejected', 'fingerprint' => '98:c2:63:c1:57:59:bc:bd:f1:ef:5a:38:b2:e9:71:c3' }
      )
    end

    test 'smart proxy page has keys link' do
      assert_row_button(smart_proxies_path, @proxy.name, 'Salt Keys', true)
    end

    test 'smart proxy details has keys link' do
      visit smart_proxy_path(@proxy)
      assert page.has_link? "Salt Keys"
      click_link "Salt Keys"
      assert page.has_content?("Salt Keys on #{@proxy.hostname}"), 'Page title does not appear'
    end

    test 'index page' do
      visit smart_proxy_salt_keys_path(:smart_proxy_id => @proxy.id)
      assert find_link('Autosign').visible?, 'Autosign is not visible'
      assert has_content?("Salt Keys on #{@proxy.hostname}"), 'Page title does not appear'
      assert has_content?('Displaying'), 'Pagination "Display ..." does not appear'
    end

    test 'has list of keys' do
      visit smart_proxy_salt_keys_path(:smart_proxy_id => @proxy.id)
      assert has_content?('saltclient01.example.com'), 'Missing key on index page'
      assert has_content?('98:c2:63:c1:57:59:bc:bd:f1:ef:5a:38:b2:e9:71:c1'), 'Missing fingerprint on index page'
    end

    test 'has accept link' do
      ProxyAPI::Salt.any_instance.stubs(:key_accept).returns(true)
      assert_row_button(smart_proxy_salt_keys_path(:smart_proxy_id => @proxy.id), 'saltclient01.example.com', 'Accept', true)
    end

    test 'has reject link' do
      ProxyAPI::Salt.any_instance.stubs(:key_reject).returns(true)
      assert_row_button(smart_proxy_salt_keys_path(:smart_proxy_id => @proxy.id), 'saltclient01.example.com', 'Reject', true)
    end
  end
end
