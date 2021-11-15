module ForemanSalt
  module Concerns
    module SaltHostgroupParameters
      extend ActiveSupport::Concern
      include Foreman::Controller::Parameters::LookupKey

      class_methods do
        def salt_hostgroup_params_filter
          Foreman::ParameterFilter.new(Hostgroup).tap do |filter|
            filter.permit hostgroup: [:salt_environment_id, :salt_proxy_id, { salt_module_ids: [] }]
            filter.permit_by_context :required, nested: true
            filter.permit_by_context :id, ui: false, api: true, nested: true

            add_lookup_key_params_filter(filter)
          end
        end
      end

      def salt_hostgroup_params
        param_name = parameter_filter_context.api? ? 'hostgroup' : 'foreman_salt_salt_hostgroup'
        self.class.salt_hostgroup_params_filter.filter_params(params, parameter_filter_context, param_name)
      end
    end
  end
end
