module ForemanSalt
  module Concerns
    module SaltModuleParameters
      extend ActiveSupport::Concern

      class_methods do
        def salt_module_params_filter
          Foreman::ParameterFilter.new(::ForemanSalt::SaltEnvironment).tap do |filter|
            filter.permit(:name, :salt_environments => [], :salt_environment_ids => [])
          end
        end
      end

      def salt_module_params
        param_name = parameter_filter_context.api? ? 'state' : 'foreman_salt_salt_module'
        self.class.salt_module_params_filter.filter_params(params, parameter_filter_context, param_name)
      end
    end
  end
end
