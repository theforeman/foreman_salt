module ForemanSalt
  module HostgroupExtensions
    extend ActiveSupport::Concern

    included do
      belongs_to :salt_proxy, :class_name => "SmartProxy"
    end

    def salt_master
      salt_proxy.to_s
    end
  end
end
