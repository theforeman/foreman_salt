module ForemanSalt
  class SaltEnvironment < ActiveRecord::Base
    include Authorizable
    extend FriendlyId
    friendly_id :name

    attr_accessible :name, :salt_modules, :salt_module_ids

    has_many :hosts, :class_name => '::Host::Managed'
    has_many :hostgroups, :class_name => '::Hostgroup'

    has_many :salt_modules, :through => :salt_module_environments, :before_remove => :remove_from_hosts
    has_many :salt_module_environments

    validates :name, :uniqueness => true, :presence => true, :format => { :with => /\A[\w\d\.]+\z/, :message => N_('is alphanumeric and cannot contain spaces') }

    scoped_search :on => :name, :complete_value => true
    scoped_search :in => :hostgroups, :on => :name, :complete_value => true, :rename => :hostgroup
    scoped_search :in => :hosts, :on => :name, :complete_value => true, :rename => :host

    def self.humanize_class_name(_name = nil)
      _('Salt environment')
    end

    def self.permission_name
      'salt_environments'
    end

    private

    def remove_from_hosts(state)
      HostSaltModule.joins(:host).where(:hosts => { :salt_environment_id => id }, :salt_module_id => state).destroy
    end
  end
end
