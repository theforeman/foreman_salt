module ForemanSalt
  module Concerns
    module HostgroupsControllerExtensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :load_vars_for_ajax, :salt_modules
      end

      private

      def load_vars_for_ajax_with_salt_modules
        load_vars_for_ajax_without_salt_modules
        @salt_modules =           @hostgroup.salt_modules
        @inherited_salt_modules = @hostgroup.inherited_salt_modules
      end
    end
  end
end
