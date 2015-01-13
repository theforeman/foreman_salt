module ForemanSalt
  module Concerns
    module HostsControllerExtensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :load_vars_for_ajax, :salt_modules
        alias_method_chain :process_hostgroup, :salt_modules
      end

      def process_hostgroup_with_salt_modules
        @hostgroup = Hostgroup.find(params[:host][:hostgroup_id]) if params[:host][:hostgroup_id].to_i > 0
        return head(:not_found) unless @hostgroup

        @salt_modules           = @host.salt_modules if @host
        @inherited_salt_modules = @hostgroup.salt_modules
        process_hostgroup_without_salt_modules
      end

      private

      def load_vars_for_ajax_with_salt_modules
        return unless @host
        @salt_modules           = @host.salt_modules
        @inherited_salt_modules = @host.hostgroup.salt_modules if @host.hostgroup
        load_vars_for_ajax_without_salt_modules
      end
    end
  end
end
