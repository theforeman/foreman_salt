module ForemanSalt
  module Concerns
    module SaltEnvironmentParameters
      extend ActiveSupport::Concern

      class_methods do
        def salt_environment_params_filter
          Foreman::ParameterFilter.new(::ForemanSalt::SaltEnvironment).tap do |filter|
            filter.permit(:name, :salt_modules => [], :salt_module_ids => [])
          end
        end
      end

      def salt_environment_params
        param_name = parameter_filter_context.api? ? 'environment' : 'foreman_salt_salt_environment'
        self.class.salt_environment_params_filter.filter_params(params, parameter_filter_context, param_name)
      end
    end
  end
end
