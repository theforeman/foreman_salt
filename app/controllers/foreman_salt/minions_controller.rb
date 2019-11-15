module ForemanSalt
  class MinionsController < ::ForemanSalt::ApplicationController
    include ::Foreman::Controller::SmartProxyAuth
    include ::Foreman::Controller::Parameters::Host

    before_action :find_resource, :only => [:node, :run]
    add_smart_proxy_filters :node, :features => 'Salt'

    def node
      enc = {}
      env = @minion.salt_environment.blank? ? 'base' : @minion.salt_environment.name
      enc['classes'] = @minion.salt_modules_for_enc

      pillars = @minion.info['parameters']
      pillars.merge!(@minion.salt_params)
      pillars.merge!('saltenv' => env)

      enc['parameters'] = Setting[:salt_namespace_pillars] ? { 'foreman' => pillars } : pillars

      enc['environment'] = env
      respond_to do |format|
        format.html { render :plain => "<pre>#{ERB::Util.html_escape(enc.to_yaml)}</pre>" }
        format.yml  { render :plain => enc.to_yaml }
      end
    rescue
      logger.warn "Failed to generate external nodes for #{@minion} with #{$ERROR_INFO}"
      render(:plain => _('Unable to generate output, Check log files\n'), :status => 412) && return
    end

    def run
      if @minion.saltrun!
        success _('Successfully executed, check log files for more details')
      else
        error @minion.errors[:base].to_sentence
      end
      redirect_to host_path(@minion)
    end

    def salt_environment_selected
      if params[:host][:salt_environment_id].present?
        @salt_environment = ::ForemanSalt::SaltEnvironment.friendly.find(params[:host][:salt_environment_id])
        load_ajax_vars
        render :partial => 'foreman_salt/salt_modules/host_tab_pane'
      else
        logger.info 'environment_id is required to render states'
      end
    end

    def action_permission
      case params[:action]
      when 'run'
        :saltrun
      when 'node'
        :view
      when 'salt_environment_selected'
        :edit
      else
        super
      end
    end

    def controller_permission
      'hosts'
    end

    def resource_class
      Host
    end

    private

    def load_ajax_vars
      @minion = Host::Base.authorized(:view_hosts, Host).find_by_id(params[:host_id])
      if @minion
        unless @minion.is_a?(Host::Managed)
          @minion      = @minion.becomes(Host::Managed)
          @minion.type = 'Host::Managed'
        end
        @minion.attributes = host_params(:host)
      else
        @minion ||= Host::Managed.new(host_params(:host))
      end

      @obj = @minion
      @inherited_salt_modules = @salt_environment.salt_modules.where(:id => @minion.hostgroup ? @minion.hostgroup.all_salt_modules : [])
      @salt_modules = @salt_environment.salt_modules - @inherited_salt_modules
      @selected = @minion.salt_modules || []
    end
  end
end
