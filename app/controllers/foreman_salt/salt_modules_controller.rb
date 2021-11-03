module ForemanSalt
  class SaltModulesController < ::ForemanSalt::ApplicationController
    include Foreman::Controller::AutoCompleteSearch
    include ::ForemanSalt::Concerns::SaltModuleParameters
    include StateImporter

    before_action :find_resource, only: %i[edit update destroy]
    before_action :find_proxy, only: :import

    def index
      @salt_modules = resource_base.search_for(params[:search], order: params[:order]).includes(:salt_environments).paginate(page: params[:page])
    end

    def new
      @salt_module = SaltModule.new
    end

    def create
      logger.info("Params: #{params.inspect}")
      @salt_module = SaltModule.new(salt_module_params)
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
      if @salt_module.update(salt_module_params)
        success _("Successfully updated #{@salt_module}.")
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

      return unless @changes.empty?
      info _('No changes found')
      redirect_to salt_modules_path
    end

    def apply_changes
      if params[:changed].blank?
        info _('No changes found')
      else
        params[:changed].each do |environment, states|
          next unless states[:add] || states[:remove]

          add_to_environment(JSON.parse(states[:add]), environment) if states[:add]
          remove_from_environment(JSON.parse(states[:remove]), environment) if states[:remove]
        end

        clean_orphans
        success _('Successfully imported')
      end
      redirect_to salt_modules_path
    end
  end
end
