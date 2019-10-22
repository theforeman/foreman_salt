module ForemanSalt
  class SaltModule < ApplicationRecord
    include Authorizable
    extend FriendlyId
    friendly_id :name
    include Parameterizable::ByIdName

    has_many :host_salt_modules, :foreign_key => :salt_module_id
    has_many :hosts, :through => :host_salt_modules, :class_name => '::Host::Managed'

    has_many :hostgroup_salt_modules, :foreign_key => :salt_module_id
    has_many :hostgroups, :through => :hostgroup_salt_modules

    has_many :salt_module_environments
    has_many :salt_environments, :through => :salt_module_environments

    validates :name, :uniqueness => true, :presence => true, :format => { :with => /\A(?:[\w\d\-]+\.{0,1})+[^\.]\z/, :message => N_('must be alphanumeric, can contain periods, dashes, underscores and must not contain spaces') }

    default_scope lambda {
      order('salt_modules.name')
    }

    scope :in_environment, ->(environment) { joins(:salt_environments).where('salt_module_environments.salt_environment_id' => environment) }

    scoped_search :on => :name, :complete_value => true
    scoped_search :relation => :salt_environments, :on => :name, :complete_value => true, :rename => :environment
    scoped_search :relation => :hostgroups, :on => :name, :complete_value => true, :rename => :hostgroup
    scoped_search :relation => :hosts, :on => :name, :complete_value => true, :rename => :host

    def self.to_hash
      states = {}

      SaltEnvironment.all.each do |environment|
        states[environment.name] = environment.salt_modules.map(&:name)
      end

      states
    end

    def self.humanize_class_name(_name = nil)
      _('Salt state')
    end

    def self.permission_name
      'salt_modules'
    end
  end
end
