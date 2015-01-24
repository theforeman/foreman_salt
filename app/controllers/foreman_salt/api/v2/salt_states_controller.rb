module ForemanSalt
  module Api
    module V2
      class SaltStatesController < ::ForemanSalt::Api::V2::BaseController
        before_filter :find_resource, :except => [:index, :create]

        api :GET, '/salt_states', N_('List all Salt states')
        def index
          @salt_states = resource_scope_for_index
        end

        api :GET, '/salt_states/:id/', N_('Show a state')
        param :id, :identifier_dottable, :required => true
        def show
        end

        def_param_group :state do
          param :state, Hash, :required => true, :action_aware => true do
            param :name, String, :required => true, :desc => N_('Name of the Salt state')
          end
        end

        api :POST, '/salt_states', N_('Create a state')
        param_group :state, :as => :create
        def create
          @salt_state = SaltModule.new(params[:state])
          process_response @salt_state.save
        end

        api :DELETE, '/salt_states/:id/', N_('Destroy a state')
        param :id, :identifier_dottable, :required => true
        def destroy
          process_response @salt_state.destroy
        end

        def controller_permission
          'salt_modules'
        end

        def resource_class
          ForemanSalt::SaltModule
        end
      end
    end
  end
end
