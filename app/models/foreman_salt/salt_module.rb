module ForemanSalt
  class SaltModule < ActiveRecord::Base
    include Taxonomix
    include Authorizable
    extend FriendlyId
    friendly_id :name

    before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)
    has_and_belongs_to_many :hosts, :class_name => '::Host::Managed', :join_table => 'hosts_salt_modules',
                            :association_foreign_key => 'host_id'

    has_and_belongs_to_many :hostgroups, :class_name => '::Hostgroup', :join_table => 'hostgroups_salt_modules'

    validates :name, :uniqueness => true, :presence => true, :format => { :with => /\A(?:[\w\d]+\.{0,1})+[^\.]\z/, :message => N_('must be alphanumeric, can contain dots and must not contain spaces') }

    default_scope lambda {
      order('salt_modules.name')
    }

    scoped_search :on => :name, :complete_value => true
    scoped_search :in => :hostgroups, :on => :name, :complete_value => true, :rename => :hostgroup
    scoped_search :in => :hosts, :on => :name, :complete_value => true, :rename => :host
  end
end
