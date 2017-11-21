module ForemanSalt
  class HostgroupSaltModule < ApplicationRecord
    belongs_to :hostgroup
    belongs_to :salt_module
  end
end
