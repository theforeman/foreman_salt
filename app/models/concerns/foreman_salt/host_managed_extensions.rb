module ForemanSalt
  module HostManagedExtensions
    extend ActiveSupport::Concern

    included do
      belongs_to :salt_proxy, :class_name => "SmartProxy"
      alias_method_chain :smart_proxy_ids, :salt_proxy
    end

    def handle_salt
      return unless salt?
      salt_autosign_create name
    end

    def saltrun!
      unless salt_proxy.present?
        errors.add(:base, _("No Salt master defined - can't continue"))
        logger.warn "unable to execute salt run, no salt proxies defined"
        return false
      end
      ProxyAPI::Salt.new({:url => salt_proxy.url}).highstate name
    rescue => e
      errors.add(:base, _("failed to execute puppetrun: %s") % e)
      false
    end

    def smart_proxy_ids_with_salt_proxy
      ids = smart_proxy_ids_without_salt_proxy
      [salt_proxy, hostgroup.try(:salt_proxy)].compact.each do |s|
        ids << s
      end
      ids
    end
  end
end
