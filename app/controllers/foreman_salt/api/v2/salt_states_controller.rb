module ForemanSalt
  module Api
    module V2
      class SaltStatesController < ::ForemanSalt::Api::V2::BaseController
        include ::ForemanSalt::Concerns::SaltModuleParameters
        include StateImporter

        before_action :find_resource, except: %i[index create import]
        before_action :find_proxy, only: :import
        before_action :find_environment, only: :index

        api :GET, '/salt_states', N_('List all Salt states')
        param :salt_environment_id, :identifier_dottable, required: false, desc: N_('Limit to a specific environment')
        param_group :search_and_pagination, ::Api::V2::BaseController
        def index
          @salt_states = if @salt_environment
                           resource_scope_for_index.joins(:salt_environments)
                                                   .where('salt_module_environments.salt_environment_id' => @salt_environment)
                         else
                           resource_scope_for_index
                         end

          @subtotal = @salt_states.count
        end

        api :GET, '/salt_states/:id/', N_('Show a state')
        param :id, :identifier_dottable, required: true
        def show
        end

        def_param_group :state do
          param :state, Hash, required: true, action_aware: true do
            param :name, String, required: true, desc: N_('Name of the Salt state')
          end
        end

        api :POST, '/salt_states', N_('Create a state')
        param_group :state, as: :create
        def create
          @salt_state = SaltModule.new(salt_module_params)
          process_response @salt_state.save
        end

        api :DELETE, '/salt_states/:id/', N_('Destroy a state')
        param :id, :identifier_dottable, required: true
        def destroy
          process_response @salt_state.destroy
        end

        api :POST, '/salt_states/import/:smart_proxy_id', N_('Import states from a salt master')
        param :smart_proxy_id, :identifier_dottable, required: true, desc: N_('Salt Smart Proxy ID')
        param :salt_environments, Array, required: false, desc: N_('Limit to a specific environments')
        param :actions, Array, required: false, desc: N_('Limit to specific actions: i.e. add, remove')
        param :dryrun, :bool, required: false, desc: N_('Dryrun only')
        def import
          states = fetch_states_from_proxy(@proxy, params[:salt_environments])

          unless params[:dryrun]
            states[:changes].each do |environment, state|
              add_to_environment(state[:add], environment) if state[:add].present? && (params[:actions].blank? || params[:actions].include?('add'))

              if state[:remove].present? && (params[:actions].blank? || params[:actions].include?('remove'))
                remove_from_environment(state[:remove], environment)
              end
            end
            clean_orphans
          end
          render plain: states.to_json
        end

        def controller_permission
          'salt_modules'
        end

        def resource_class
          ForemanSalt::SaltModule
        end

        def action_permission
          case params[:action]
          when 'import'
            :import
          else
            super
          end
        end

        private

        def find_environment
          return unless params[:salt_environment_id]
          @salt_environment = ForemanSalt::SaltEnvironment.friendly.find(params[:salt_environment_id])
          raise _('Could not find salt environment with id %s') % params[:salt_environment_id] unless @salt_environment
        end
      end
    end
  end
end
