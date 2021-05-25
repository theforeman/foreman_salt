module ForemanSalt
  module Concerns
    module HostManagedExtensions
      extend ActiveSupport::Concern

      module Overrides
        def configuration?
          super || !!salt_proxy
        end

        def params
          params = super
          params['salt_master'] = salt_master unless salt_master.blank?
          params
        end

        def smart_proxy_ids
          ids = super
          [salt_proxy, hostgroup.try(:salt_proxy)].compact.each do |proxy|
            ids << proxy.id
          end
          ids
        end

        def inherited_attributes
          super + %w(salt_proxy_id salt_environment_id)
        end
      end

      included do
        has_many :host_salt_modules, :foreign_key => :host_id, :class_name => '::ForemanSalt::HostSaltModule'
        has_many :salt_modules, :through => :host_salt_modules, :class_name => '::ForemanSalt::SaltModule'

        belongs_to :salt_proxy, :class_name => 'SmartProxy'
        belongs_to :salt_environment, :class_name => 'ForemanSalt::SaltEnvironment'

        prepend Overrides

        scoped_search :relation => :salt_modules, :on => :name, :complete_value => true, :rename => :salt_state
        scoped_search :relation => :salt_environment, :on => :name, :complete_value => true, :rename => :salt_environment
        scoped_search :relation => :salt_proxy, :on => :name, :complete_value => true, :rename => :saltmaster

        validate :salt_modules_in_host_environment

        after_build      :delete_salt_key, :if => ->(host) { host.salt_proxy }
        before_provision :accept_salt_key, :if => ->(host) { host.salt_proxy }
        before_destroy   :delete_salt_key, :if => ->(host) { host.salt_proxy }
        after_update     :refresh_pillar, :if => ->(host) { host.salt_proxy }
      end

      def salt_params
        variables = ForemanSalt::SaltVariable.where(:salt_module_id => all_salt_modules.pluck(:id), :override => true)
        values = variables.values_hash(self)

        variables.each_with_object({}) do |var, memo|
          value = values[var]
          memo[var.key] = value if value
          memo
        end
      end

      def salt_modules_for_enc
        all_salt_modules.collect(&:name).uniq
      end

      def all_salt_modules
        return [] unless salt_environment

        modules = salt_modules + (hostgroup ? hostgroup.all_salt_modules : [])
        ForemanSalt::SaltModule.in_environment(salt_environment).where(:id => modules)
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

      def salt_modules_in_host_environment
        return unless self.salt_modules.any?

        if self.salt_environment
          errors.add(:base, _('Salt states must be in the environment of the host')) unless (self.salt_modules - self.salt_environment.salt_modules).empty?
        else
          errors.add(:base, _('Host must have an environment in order to set salt states'))
        end
      end

      private

      def refresh_pillar
        unless salt_proxy.present?
          errors.add(:base, _("No Salt master defined - can't continue"))
          logger.warn 'Unable to refresh pillar data, no salt proxies defined'
          return false
        end
        begin
          Rails.logger.info("Refreshing pillar data of #{fqdn}")
          ProxyAPI::Salt.new(:url => salt_proxy.url).refresh_pillar name
        rescue => e
          errors.add(:base, _('Failed to refresh pillar data: %s') % e)
          false
        end
      end

      def accept_salt_key
        begin
          Rails.logger.info("Host #{fqdn} is built, accepting Salt key")
          key = ForemanSalt::SmartProxies::SaltKeys.find(salt_proxy, fqdn)
          key&.accept
        rescue Foreman::Exception => e
          Rails.logger.warn("Unable to accept key for #{fqdn}: #{e}")
        end
      end

      def delete_salt_key
        begin
          key = ForemanSalt::SmartProxies::SaltKeys.find(salt_proxy, fqdn)
          key&.delete
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
