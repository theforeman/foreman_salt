module ForemanSalt
  module Concerns
    module HostsControllerExtensions
      extend ActiveSupport::Concern

      module Overrides
        def process_hostgroup
          @hostgroup = Hostgroup.find(params[:host][:hostgroup_id]) if params[:host][:hostgroup_id].to_i > 0
          return head(:not_found) unless @hostgroup

          @salt_modules           = @host.salt_modules if @host
          @salt_environment       = @host.salt_environment if @host
          @inherited_salt_modules = @hostgroup.all_salt_modules
          super
        end

        private

        def load_vars_for_ajax
          return unless @host

          @obj                    = @host
          @salt_environment       = @host.salt_environment if @host
          @selected               = @host.salt_modules
          @salt_modules           = @host.salt_environment ? @salt_environment.salt_modules : []
          @inherited_salt_modules = @host.hostgroup.all_salt_modules if @host.hostgroup
          super
        end
      end

      included do
        prepend Overrides
      end
    end
  end
end
