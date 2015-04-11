module ForemanSalt
  class SaltModulesController < ::ForemanSalt::ApplicationController
    include Foreman::Controller::AutoCompleteSearch
    include StateImporter

    before_filter :find_resource, :only => [:edit, :update, :destroy]
    before_filter :find_proxy, :only => :import

    def index
      @salt_modules = resource_base.search_for(params[:search], :order => params[:order]).includes(:salt_environments).paginate(:page => params[:page])
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
      @salt_environments = @salt_module.salt_environments
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

    def action_permission
      case params[:action]
      when 'import'
        :import
      when 'apply_changes'
        :import
      else
        super
      end
    end

    def import
      result = fetch_states_from_proxy(@proxy)
      @changes = result[:changes]
      @deletes = result[:deletes]

      if @changes.empty?
        notice _('No changes found')
        redirect_to salt_modules_path
      end
    end

    def apply_changes
      if params[:changed].blank?
        notice _('No changes found')
        redirect_to salt_modules_path
      else
        params[:changed].each do |environment, states|
          next unless states[:add] || states[:remove]
          environment = SaltEnvironment.find_or_create_by_name(environment)

          add_to_environment(JSON.load(states[:add]), environment) if states[:add]
          remove_from_environment(JSON.load(states[:remove]), environment) if states[:remove]
        end

        clean_orphans
        notice _('Successfully imported')
        redirect_to salt_modules_path
      end
    end
  end
end
