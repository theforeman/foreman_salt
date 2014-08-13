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

    def smart_proxy_ids_with_salt_proxy
      ids = smart_proxy_ids_without_salt_proxy
      [salt_proxy, hostgroup.try(:salt_proxy)].compact.each do |s|
        ids << s
      end
      ids
    end
  end
end
