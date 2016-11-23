module ForemanSalt
  module Concerns
    module HostManagedExtensions
      extend ActiveSupport::Concern

      included do
        has_many :salt_modules, :through => :host_salt_modules, :class_name => '::ForemanSalt::SaltModule'
        has_many :host_salt_modules, :foreign_key => :host_id, :class_name => '::ForemanSalt::HostSaltModule'

        belongs_to :salt_proxy, :class_name => 'SmartProxy'
        belongs_to :salt_environment, :class_name => 'ForemanSalt::SaltEnvironment'

        alias_method_chain :params, :salt_proxy
        alias_method_chain :set_hostgroup_defaults, :salt_proxy
        alias_method_chain :smart_proxy_ids, :salt_proxy
        alias_method_chain :configuration?, :salt

        scoped_search :in => :salt_modules, :on => :name, :complete_value => true, :rename => :salt_state
        scoped_search :in => :salt_environment, :on => :name, :complete_value => true, :rename => :salt_environment
        scoped_search :in => :salt_proxy, :on => :name, :complete_value => true, :rename => :saltmaster

        validate :salt_modules_in_host_environment

        after_build      :delete_salt_key, :if => ->(host) { host.salt_proxy }
        before_provision :accept_salt_key, :if => ->(host) { host.salt_proxy }
        before_destroy   :delete_salt_key, :if => ->(host) { host.salt_proxy }
      end

      def configuration_with_salt?
        configuration_without_salt? || !!salt_proxy
      end

      def params_with_salt_proxy
        params = params_without_salt_proxy
        params['salt_master'] = salt_master unless salt_master.blank?
        params
      end

      def salt_modules_for_enc
        return [] unless salt_environment
        modules = salt_modules + (hostgroup ? hostgroup.all_salt_modules : [])
        ForemanSalt::SaltModule.in_environment(salt_environment).where(:id => modules).pluck("salt_modules.name").uniq
      end

      def salt_master
        salt_proxy.to_s
      end

      def saltrun!
        unless salt_proxy.present?
          errors.add(:base, _("No Salt master defined - can't continue"))
          logger.warn 'Unable to execute salt run, no salt proxies defined'
          return false
        end
        ProxyAPI::Salt.new(:url => salt_proxy.url).highstate name
      rescue => e
        errors.add(:base, _('Failed to execute state.highstate: %s') % e)
        false
      end

      def set_hostgroup_defaults_with_salt_proxy
        return unless hostgroup
        assign_hostgroup_attributes(%w(salt_proxy_id salt_environment_id))
        set_hostgroup_defaults_without_salt_proxy
      end

      def smart_proxy_ids_with_salt_proxy
        ids = smart_proxy_ids_without_salt_proxy
        [salt_proxy, hostgroup.try(:salt_proxy)].compact.each do |proxy|
          ids << proxy.id
        end
        ids
      end

      def salt_modules_in_host_environment
        return unless self.salt_modules.any?

        if self.salt_environment
          errors.add(:base, _('Salt states must be in the environment of the host')) unless (self.salt_modules - self.salt_environment.salt_modules).empty?
        else
          errors.add(:base, _('Host must have an environment in order to set salt states'))
        end
      end

      private

      def accept_salt_key
        begin
          Rails.logger.info("Host #{fqdn} is built, accepting Salt key")
          key = ForemanSalt::SmartProxies::SaltKeys.find(salt_proxy, fqdn)
          key.accept unless key.nil?
        rescue Foreman::Exception => e
          Rails.logger.warn("Unable to accept key for #{fqdn}: #{e}")
        end
      end

      def delete_salt_key
        begin
          key = ForemanSalt::SmartProxies::SaltKeys.find(salt_proxy, fqdn)
          key.delete unless key.nil?
        rescue Foreman::Exception => e
          Rails.logger.warn("Unable to delete key for #{fqdn}: #{e}")
        end
      end
    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :salt_environment
end
