module ForemanSalt
  module Api
    module V2
      class SaltMinionsController < ::ForemanSalt::Api::V2::BaseController
        before_action :find_resource, :except => [:index]

        api :GET, '/salt_minions', N_('List all Salt Minions')
        param_group :search_and_pagination, ::Api::V2::BaseController
        def index
          @salt_minions = resource_scope_for_index
        end

        api :GET, '/salt_minions/:id', N_('Show a minion')
        param :id, :identifier_dottable, :required => true
        def show
          @salt_states = @salt_minion.salt_modules
        end

        def_param_group :minion do
          param :minion, Hash, :required => true, :action_aware => true do
            param :salt_environment_id, :number, :desc => N_('Salt environment ID')
            param :salt_proxy_id, :number, :desc => N_('ID of Salt Proxy')
            param :salt_state_ids, Array, :desc => N_('Array of State ids')
          end
        end

        api :PUT, '/salt_minions/:id/', N_('Update a minion')
        param :id, :identifier_dottable, :required => true
        param_group :minion
        def update
          params[:minion][:salt_module_ids] = params[:minion].delete(:salt_state_ids) if params[:minion]
          process_response @salt_minion.update_attributes(params[:minion])
        end

        def controller_permission
          'hosts'
        end

        def resource_class
          Host
        end
      end
    end
  end
end
