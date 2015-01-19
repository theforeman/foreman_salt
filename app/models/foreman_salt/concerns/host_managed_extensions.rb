module ForemanSalt
  module Concerns
    module HostManagedExtensions
      extend ActiveSupport::Concern

      included do
        has_and_belongs_to_many :salt_modules, :class_name => 'ForemanSalt::SaltModule', :join_table => 'hosts_salt_modules', :foreign_key => 'host_id'
        belongs_to :salt_proxy, :class_name => 'SmartProxy'
        belongs_to :salt_environment, :class_name => 'ForemanSalt::SaltEnvironment'
        alias_method_chain :params, :salt_proxy
        alias_method_chain :set_hostgroup_defaults, :salt_proxy
        alias_method_chain :smart_proxy_ids, :salt_proxy
      end

      def handle_salt
        return true unless salt?
        set_salt_autosign
      end

      def params_with_salt_proxy
        params = params_without_salt_proxy
        params['salt_master'] = salt_master unless salt_master.blank?
        params
      end

      def salt_modules
        return super unless hostgroup
        [super + hostgroup.salt_modules].flatten
      end

      def salt_module_ids
        return super unless hostgroup
        [super + hostgroup.salt_module_ids].flatten
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
    end
  end
end
