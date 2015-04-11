module ForemanSalt
  class HostSaltModule < ActiveRecord::Base
    belongs_to :host, :class_name => "Host::Managed", :foreign_key => :host_id
    belongs_to :salt_module
  end
end
