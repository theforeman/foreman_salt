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

        after_build :ensure_salt_autosign, :if => ->(host) { host.salt_proxy }
        before_destroy :remove_salt_autosign, :if => ->(host) { host.salt_proxy }
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

      def host_params_grains_name
        "salt_grains"
      end

      def autosign_grain_name
        "autosign_key"
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

      def ensure_salt_autosign
        remove_salt_autosign
        create_salt_autosign
      end

      def remove_salt_autosign
        key = self.salt_autosign_key
        unless key.nil?
          Rails.logger.info("Remove salt autosign key for host #{fqdn}")
          begin
            api = ProxyAPI::Salt.new(:url => salt_proxy.url)
            api.autosign_remove_key(key)
          rescue Foreman::Exception => e
            Rails.logger.warn("Unable to remove salt autosign for #{fqdn}: #{e}")
          end
        end
      end

      def generate_provisioning_key
          SecureRandom.hex(10)
      end

      def create_salt_autosign
        begin
          Rails.logger.info("Create salt autosign key for host #{fqdn}")
          api = ProxyAPI::Salt.new(:url => salt_proxy.url)
          key = generate_provisioning_key
          api.autosign_create_key(key)
          update(:salt_autosign_key => key)
          update(:salt_status => ForemanSalt::SaltStatus.minion_auth_waiting)
        rescue Foreman::Exception => e
          Rails.logger.warn("Unable to create salt autosign for #{fqdn}: #{e}")
        end
      end

      def derive_salt_grains(use_autosign: False)
        grains = {}
        begin
          Rails.logger.info("Derive Salt Grains from host_params and autosign_key")
          grains[autosign_grain_name] = salt_autosign_key if use_autosign && !salt_autosign_key.nil?
          unless host_params[host_params_grains_name].nil?
            grains.merge!(host_params[host_params_grains_name])
          end
        rescue Foreman::Exception => e
          Rails.logger.warn("Unable to derive Salt Grains: #{e}")
        end
        grains
      end
    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :salt_environment, :salt_master, :derive_salt_grains
end
