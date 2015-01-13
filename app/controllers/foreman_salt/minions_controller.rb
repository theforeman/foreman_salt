module ForemanSalt
  class MinionsController < ApplicationController
    include ::Foreman::Controller::SmartProxyAuth

    before_filter :find_resource, :only => [:node, :run]
    add_smart_proxy_filters :node, :features => 'Salt'

    def node
      begin
        enc = {}
        env = @minion.salt_environment.blank? ? 'base' : @minion.salt_environment.name
        enc['classes'] = @minion.salt_modules.any? ? @minion.salt_modules.map(&:name) : []
        enc['parameters'] = @minion.info['parameters']
        enc['environment'] = env
        respond_to do |format|
          format.html { render :text => "<pre>#{ERB::Util.html_escape(enc.to_yaml)}</pre>" }
          format.yml  { render :text => enc.to_yaml }
        end
      rescue
        logger.warn "Failed to generate external nodes for #{@minion} with #{$!}"
        render :text => _('Unable to generate output, Check log files\n'), :status => 412 and return
      end
    end

    def run
      if @minion.saltrun!
        notice _('Successfully executed, check log files for more details')
      else
        error @minion.errors[:base].to_sentence
      end
      redirect_to host_path(@minion)
    end

    def action_permission
      case params[:action]
        when 'run'
          :saltrun
        when 'node'
          :view
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
  end
end
