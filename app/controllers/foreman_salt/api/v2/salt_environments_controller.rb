module ForemanSalt
  module Api
    module V2
      class SaltEnvironmentsController < ::ForemanSalt::Api::V2::BaseController
        before_action :find_resource, :except => [:index, :create]

        api :GET, '/salt_environments', N_('List all Salt environments')
        param_group :search_and_pagination, ::Api::V2::BaseController
        def index
          @salt_environments = resource_scope_for_index
        end

        api :GET, '/salt_environments/:id/', N_('Show a Salt environment')
        param :id, :identifier_dottable, :required => true
        def show
        end

        def_param_group :environment do
          param :environment, Hash, :required => true, :action_aware => true do
            param :name, String, :required => true
          end
        end

        api :POST, '/salt_environments', N_('Create a Salt environment')
        param_group :environment, :as => :create
        def create
          @salt_environment = SaltEnvironment.new(params[:environment])
          process_response @salt_environment.save
        end

        api :DELETE, '/salt_environments/:id/', N_('Destroy a Salt environment')
        param :id, :identifier, :required => true
        def destroy
          process_response @salt_environment.destroy
        end

        def controller_permission
          'salt_environments'
        end

        def resource_class
          ForemanSalt::SaltEnvironment
        end
      end
    end
  end
end
