FactoryBot.define do
  factory :salt_module, :class => 'ForemanSalt::SaltModule' do
    sequence(:name) { |n| "module#{n}" }
  end

  factory :salt_environment, :class => 'ForemanSalt::SaltEnvironment' do
    sequence(:name) { |n| "environment#{n}" }
  end
end

FactoryBot.modify do
  factory :host do
    trait :with_salt_proxy do
      salt_proxy { FactoryBot.build :smart_proxy, :with_salt_feature }
    end
  end

  factory :hostgroup do
    trait :with_salt_proxy do
      salt_proxy { FactoryBot.build :smart_proxy, :with_salt_feature }
    end

    trait :with_salt_modules do
      salt_environment { FactoryBot.build :salt_environment }
      salt_modules { FactoryBot.create_list :salt_module, 10, :salt_environments => [self.salt_environment] }
    end
  end

  factory :smart_proxy do
    trait :with_salt_feature do
      features { [::Feature.where(:name => 'Salt').first_or_create] }
    end
  end
end
