require 'test_plugin_helper'

class SaltVariablesTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
    @state = FactoryBot.create :salt_module
  end

  test 'salt variable has a salt module' do
    salt_variable = ForemanSalt::SaltVariable.new(:key => 'awesome_key', :salt_module_id => @state.id)
    assert_valid salt_variable
    assert_equal true, salt_variable.salt?
    assert_equal @state.id, salt_variable.salt_module.id
  end

  test 'salt variable is referencing a LookupValue' do
    salt_variable = ForemanSalt::SaltVariable.new(:key => 'awesome_key', :salt_module_id => @state.id)
    assert salt_variable.lookup_values.count.zero?
    LookupValue.create(:value => "[1.2.3.4,2.3.4.5]", :match => "domain =  mydomain.net", :lookup_key => salt_variable)
    assert salt_variable.lookup_values.count == 1
  end

  test 'should cast default_value to hash' do
    salt_variable = ForemanSalt::SaltVariable.new(:key => 'awesome_key',
                                                  :salt_module_id => @state.id,
                                                  :key_type => 'hash',
                                                  :default_value => "{\r\n  \"bat\": \"man\"\r\n}\r\n",
                                                  :override => true)
    salt_variable.save
    assert salt_variable.default_value.is_a?(Hash)
  end
end
