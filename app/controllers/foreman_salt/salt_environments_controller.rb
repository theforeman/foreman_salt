module ForemanSalt
  class SaltEnvironmentsController < ::ApplicationController
    include Foreman::Controller::AutoCompleteSearch

    before_filter :find_by_name, :only => [:edit, :update, :destroy]

    def index
      @salt_environments = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
    end

    def new
      @salt_environment = SaltEnvironment.new
    end

    def create
      logger.info("Params: #{params.inspect}")
      @salt_environment = SaltEnvironment.new(params[:foreman_salt_salt_environment])
      if @salt_environment.save
        process_success
      else
        process_error
      end
    end

    def edit
    end

    def update
      if @salt_environment.update_attributes(params[:foreman_salt_salt_environment])
        notice _("Successfully updated %s." % @salt_environment.to_s)
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
