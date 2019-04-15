require 'test_plugin_helper'

class SaltModulesTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  test 'salt module has a valid name' do
    salt_module = ForemanSalt::SaltModule.new(:name => 'foo.bar.baz')
    assert_valid salt_module
  end

  test 'salt module has invalid name' do
    salt_module = ForemanSalt::SaltModule.new(:name => '&bad$name')
    refute_valid salt_module, :name, /alphanumeric/
  end
end
