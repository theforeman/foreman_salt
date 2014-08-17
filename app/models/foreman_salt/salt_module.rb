module ForemanSalt
  class SaltModule < ActiveRecord::Base
    include Taxonomix
    include Authorizable

    has_and_belongs_to_many :hosts, :class_name => "::Host::Managed", :join_table => "hosts_salt_modules",
                            :association_foreign_key => 'host_id'
    validates :name, :uniqueness => true, :presence => true, :format => { :with => /\A[\w\d]+\z/, :message => N_("is alphanumeric and cannot contain spaces") }

    default_scope lambda {
      with_taxonomy_scope do
        order("salt_modules.name")
      end
    }

  end
end
