module ForemanSalt
  class HostSaltModule < ApplicationRecord
    belongs_to :host, class_name: 'Host::Managed'
    belongs_to :salt_module
  end
end
