module ForemanSalt
  class SaltModulesController < ApplicationController
    include Foreman::Controller::AutoCompleteSearch

    before_filter :find_resource, :only => [:edit, :update, :destroy]

    def index
      @salt_modules = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
    end

    def new
      @salt_module = SaltModule.new
    end

    def create
      logger.info("Params: #{params.inspect}")
      @salt_module = SaltModule.new(params[:foreman_salt_salt_module])
      if @salt_module.save
        process_success
      else
        process_error
      end
    end

    def edit
    end

    def update
      if @salt_module.update_attributes(params[:foreman_salt_salt_module])
        notice _('Successfully updated %s.' % @salt_module.to_s)
        redirect_to salt_modules_path
      else
        process_error
      end
    end

    def destroy
      if @salt_module.destroy
        process_success
      else
        process_error
      end
    end
  end
end
