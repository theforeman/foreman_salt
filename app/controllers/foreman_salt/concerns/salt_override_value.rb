# frozen_string_literal: true

module ForemanSalt
  module Concerns
    # Keys to allow as parameters in the SaltVariable controller
    module SaltOverrideValue
      extend ActiveSupport::Concern

      class_methods do
        def lookup_value_params_filter
          Foreman::ParameterFilter.new(::LookupValue).tap do |filter|
            filter.permit :salt_variable_id, override_value: {}

            filter.permit_by_context :hidden_value, :host_or_hostgroup, :lookup_key, :lookup_key_id,
              :match, :omit, :value, nested: true

            filter.permit_by_context :id, :_destroy, ui: false,
                                                     api: false, nested: true
          end
        end
      end

      def lookup_value_params
        self.class.lookup_value_params_filter.filter_params(params, parameter_filter_context, 'foreman_salt_salt_variable')
      end
    end
  end
end
