module ForemanSalt
  module HostgroupExtensions
    extend ActiveSupport::Concern

    included do
      belongs_to :salt_proxy, :class_name => "SmartProxy"
    end

    def salt_proxy
      return super unless ancestry.present?
      SmartProxy.find_by_id(inherited_salt_proxy_id)
    end

    def inherited_salt_proxy_id
      if ancestry.present?
        self[:inherited_salt_proxy_id] || self.class.sort_by_ancestry(ancestors.where("salt_proxy_id is not NULL")).last.try(:salt_proxy_id)
      else
        self.salt_proxy_id
      end
    end

    def salt_master
      salt_proxy.to_s
    end
  end
end
