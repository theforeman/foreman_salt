module ForemanSalt
  class SaltEnvironmentsController < ::ForemanSalt::ApplicationController
    include Foreman::Controller::AutoCompleteSearch
    include ::ForemanSalt::Concerns::SaltEnvironmentParameters

    before_action :find_resource, only: %i[edit update destroy]

    def index
      @salt_environments = resource_base.search_for(params[:search], order: params[:order]).paginate(page: params[:page])
    end

    def new
      @salt_environment = SaltEnvironment.new
    end

    def create
      @salt_environment = SaltEnvironment.new(salt_environment_params)
      if @salt_environment.save
        process_success
      else
        process_error
      end
    end

    def edit
    end

    def update
      if @salt_environment.update(salt_environment_params)
        success _("Successfully updated #{@salt_environment}")
        redirect_to salt_environments_path
      else
        process_error
      end
    end

    def destroy
      if @salt_environment.destroy
        process_success
      else
        process_error
      end
    end
  end
end
