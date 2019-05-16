# frozen_string_literal: true

module ForemanSalt
  module Concerns
    # Keys to allow as parameters in the SaltVariable controller
    module SaltVariableParameters
      extend ActiveSupport::Concern
      include Foreman::Controller::Parameters::LookupKey

      class_methods do
        def salt_variable_params_filter
          Foreman::ParameterFilter.new(::ForemanSalt::SaltVariable).tap do |filter|
            filter.permit :salt_module_id,
              :salt_modules => [], :salt_module_ids => [],
              :salt_module_names => [],
              :param_classes => [], :param_classes_ids => [],
              :param_classes_names => []
            filter.permit_by_context :required, :nested => true
            filter.permit_by_context :id, :ui => false, :api => false,
              :nested => true

            add_lookup_key_params_filter(filter)
          end
        end
      end

      def salt_variable_params
        param_name = parameter_filter_context.api? ? 'salt_variable' : 'foreman_salt_salt_variable'
        self.class.salt_variable_params_filter.filter_params(params, parameter_filter_context, param_name)
      end
    end
  end
end
