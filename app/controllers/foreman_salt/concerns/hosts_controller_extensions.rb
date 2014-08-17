module ForemanSalt
  module Concerns
    module HostsControllerExtensions
      extend ActiveSupport::Concern

      included do
        alias_method :find_by_name_salt, :find_by_name
        before_filter :find_by_name_salt, :only => [:saltrun]
        alias_method_chain :action_permission, :salt_run
        alias_method_chain :load_vars_for_ajax, :salt_modules
        add_puppetmaster_filters [:salt_external_node]
      end

      def saltrun
        if @host.saltrun!
          notice _("Successfully executed, check log files for more details")
        else
          error @host.errors[:base].to_sentence
        end
        redirect_to host_path(@host)
      end

      def salt_external_node
        begin
          @host ||= resource_base.find_by_name(params[:name])
          enc = {}
          enc["classes"] = @host.salt_modules.any? ? @host.salt_modules.map(&:name) : []
          enc["parameters"] = @host.info["parameters"]
          respond_to do |format|
            format.html { render :text => "<pre>#{ERB::Util.html_escape(enc.to_yaml)}</pre>" }
            format.yml  { render :text => enc.to_yaml }
          end
        rescue
          logger.warn "Failed to generate external nodes for #{@host} with #{$!}"
          render :text => _('Unable to generate output, Check log files\n'), :status => 412 and return
        end
      end

      private

      def action_permission_with_salt_run
        case params[:action]
          when 'saltrun'
            :saltrun
          when 'salt_external_node'
            :view
          else
            action_permission_without_salt_run
        end
      end

      def load_vars_for_ajax_with_salt_modules
        @salt_modules = @host.salt_modules
        logger.info("Salt modules for this host: #{@salt_modules.inspect}")
        load_vars_for_ajax_without_salt_modules
      end
    end
  end
end
