module ForemanSalt
  module Api
    module V2
      class SaltHostgroupsController < ::ForemanSalt::Api::V2::BaseController
        include ::ForemanSalt::Concerns::SaltHostgroupParameters

        before_action :find_resource

        api :GET, '/hostgroups/:id', N_('Show the Salt parameters of a host group')
        param :id, :identifier_dottable, required: true, desc: N_('ID of host group')
        def show
          @salt_hostgroup
        end

        def_param_group :salt_attributes do
          param :hostgroup, Hash, required: true, action_aware: true do
            param :salt_environment_id, :number, desc: N_('Salt environment ID')
            param :salt_proxy_id, :number, desc: N_('Salt master/smart proxy ID')
            param :salt_state_ids, Array, desc: N_('Array of Salt state IDs')
          end
        end

        api :PUT, '/hostgroups/:id', N_('Update the Salt parameters of a host group')
        param :id, :identifier_dottable, required: true, desc: N_('ID of host group')
        param_group :salt_attributes
        def update
          params.extract!(:salt_hostgroup) if params[:salt_hostgroup]
          params[:hostgroup][:salt_module_ids] = params[:hostgroup].delete(:salt_state_ids) if params[:hostgroup][:salt_state_ids]
          process_response @salt_hostgroup.update(salt_hostgroup_params)
        end

        def controller_permission
          'hostgroups'
        end

        def resource_class
          Hostgroup
        end
      end
    end
  end
end
