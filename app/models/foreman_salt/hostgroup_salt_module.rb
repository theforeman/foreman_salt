module ForemanSalt
  class HostgroupSaltModule < ActiveRecord::Base
    belongs_to :hostgroup
    belongs_to :salt_module
  end
end
