FactoryBot.define do
  factory :salt_module, class: 'ForemanSalt::SaltModule' do
    sequence(:name) { |n| "module#{n}" }
  end

  factory :salt_environment, class: 'ForemanSalt::SaltEnvironment' do
    sequence(:name) { |n| "environment#{n}" }
  end

  factory :salt_variable, class: 'ForemanSalt::SaltVariable' do
    sequence(:key) { |n| "salt_variable_#{n}" }
    sequence(:default_value) { |n| "default_value_#{n}" }
    salt_module
  end
end

FactoryBot.modify do
  factory :hostgroup do
    trait :with_salt_modules do
      salt_environment { FactoryBot.build :salt_environment }
      salt_modules { FactoryBot.create_list :salt_module, 10, salt_environments: [salt_environment] }
    end
  end

  factory :smart_proxy do
    trait :with_salt_feature do
      features { [::Feature.find_or_create_by(name: 'Salt')] }
    end
  end
end
