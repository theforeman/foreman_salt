module ForemanSalt
  class SaltModuleEnvironment < ActiveRecord::Base
    belongs_to :salt_environment
    belongs_to :salt_module

    before_destroy :remove_from_hosts

    private

    def remove_from_hosts
      HostSaltModule.joins(:host).where(:hosts => { :salt_environment_id => salt_environment_id }, :salt_module_id => salt_module_id).destroy
    end
  end
end
