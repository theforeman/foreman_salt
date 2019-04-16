require 'test_plugin_helper'

class SaltKeysTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin

    # Fix for 1.8.7 OpenStruct http://stackoverflow.com/questions/9079441/populate-select-tag-ruby-rails
    OpenStruct.__send__(:define_method, :id) { @table[:id] }

    @proxy = OpenStruct.new(:id => 1, :url => 'http://dummy.example.com:9090')

    ProxyAPI::Salt.any_instance.stubs(:key_list).returns(
      'saltstack.example.com' => { 'state' => 'accepted', 'fingerprint' => '98:c2:63:c1:57:59:bc:bd:f1:ef:5a:38:b2:e9:71:c0' },
      'saltclient01.example.com' => { 'state' => 'unaccepted', 'fingerprint' => '98:c2:63:c1:57:59:bc:bd:f1:ef:5a:38:b2:e9:71:c1' },
      'saltclient02.example.com' => { 'state' => 'unaccepted', 'fingerprint' => '98:c2:63:c1:57:59:bc:bd:f1:ef:5a:38:b2:e9:71:c2' },
      'saltclient03.example.com' => { 'state' => 'rejected', 'fingerprint' => '98:c2:63:c1:57:59:bc:bd:f1:ef:5a:38:b2:e9:71:c3' }
    )
  end

  test 'key has a name' do
    assert_not_empty ForemanSalt::SmartProxies::SaltKeys.all(@proxy).first.name
  end

  test 'key has a state' do
    assert_not_empty ForemanSalt::SmartProxies::SaltKeys.all(@proxy).first.state
  end

  test 'key has a fingerprint' do
    assert_not_empty ForemanSalt::SmartProxies::SaltKeys.all(@proxy).first.fingerprint
  end

  test 'key has a smart proxy id' do
    assert_equal 1, ForemanSalt::SmartProxies::SaltKeys.all(@proxy).first.smart_proxy_id
  end

  test 'returns all keys' do
    assert_equal 4, ForemanSalt::SmartProxies::SaltKeys.all(@proxy).count
  end

  test 'finds a key by name' do
    assert_equal ForemanSalt::SmartProxies::SaltKeys.find(@proxy, 'saltstack.example.com').name, 'saltstack.example.com'
  end

  test 'find keys by state' do
    assert_equal 2, ForemanSalt::SmartProxies::SaltKeys.find_by_state(@proxy, 'unaccepted').count
  end
end
