module ForemanSalt
  module HostgroupExtensions
    extend ActiveSupport::Concern

    included do
      belongs_to :salt_proxy, :class_name => "SmartProxy"
    end
  end
end
