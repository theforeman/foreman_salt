# frozen_string_literal: true

module ForemanSalt
  module Api
    module V2
      # API controller for Salt Variables
      class SaltVariablesController < ::ForemanSalt::Api::V2::BaseController
        include ::ForemanSalt::Concerns::SaltVariableParameters

        wrap_parameters :salt_variable, :include => salt_variable_params_filter.accessible_attributes(parameter_filter_context) + ['salt_state_id']
        before_action :find_resource, :only => [:show, :destroy, :update]

        api :GET, '/salt_variables/:id', N_('Show variable')
        param :id, :identifier, :required => true
        def show; end

        api :GET, '/salt_variables', N_('List Salt variables')
        param_group :search_and_pagination, ::Api::V2::BaseController
        def index
          @salt_variables = resource_scope_for_index
        end

        api :DELETE, '/salt_variables/:id', N_('Deletes Salt variable')
        param :id, :identifier, :required => true
        def destroy
          @salt_variable.destroy
          render 'foreman_salt/api/v2/salt_variables/destroy'
        end

        def_param_group :salt_variable do
          param :salt_variable, Hash, :required => true, :action_aware => true do
            param :variable, String, :required => true, :desc => N_("Name of variable")
            param :salt_state_id, :number, :required => true, :desc => N_("State ID")
            param :default_value, :any_type, :of => LookupKey::KEY_TYPES, :desc => N_("Default value of variable")
            param :hidden_value, :bool, :desc => N_("When enabled the parameter is hidden in the UI")
            param :override_value_order, String, :desc => N_("The order in which values are resolved")
            param :description, String, :desc => N_("Description of variable")
            param :validator_type, LookupKey::VALIDATOR_TYPES, :desc => N_("Types of validation values")
            param :validator_rule, String, :desc => N_("Used to enforce certain values for the parameter values")
            param :variable_type, LookupKey::KEY_TYPES, :desc => N_("Types of variable values")
            param :merge_overrides, :bool, :desc => N_("Merge all matching values (only array/hash type)")
            param :merge_default, :bool, :desc => N_("Include default value when merging all matching values")
            param :avoid_duplicates, :bool, :desc => N_("Remove duplicate values (only array type)")
          end
        end

        api :POST, '/salt_variables', N_('Create Salt variable')
        param_group :salt_variable, :as => :create
        def create
          params[:salt_variable][:salt_module_id] = params[:salt_variable].delete(:salt_state_id) if params[:salt_variable]
          @salt_variable = SaltVariable.new(salt_variable_params)
          process_response @salt_variable.save
        end

        api :PUT, '/salt_variables/:id', N_('Updates Salt variable')
        param :id, :identifier, :required => true
        param_group :salt_variable, :as => :update

        def update
          @salt_variable.update!(salt_variable_params)
          render 'foreman_salt/api/v2/salt_variables/show'
        end

        def controller_permission
          'salt_variables'
        end

        def resource_class
          ForemanSalt::SaltVariable
        end
      end
    end
  end
end
