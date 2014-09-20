module ForemanSalt
  class SaltEnvironment < ActiveRecord::Base
    include Taxonomix
    include Authorizable

    before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)

    has_many :hosts, :class_name => "::Host::Managed"
    has_many :hostgroups, :class_name => "::Hostgroup"

    validates :name, :uniqueness => true, :presence => true, :format => { :with => /\A[\w\d\.]+\z/, :message => N_("is alphanumeric and cannot contain spaces") }

    default_scope lambda {
      order("salt_environments.name")
    }

    scoped_search :on => :name, :complete_value => true
    scoped_search :in => :hostgroups, :on => :name, :complete_value => true, :rename => :hostgroup
    scoped_search :in => :hosts, :on => :name, :complete_value => true, :rename => :host
  end
end
