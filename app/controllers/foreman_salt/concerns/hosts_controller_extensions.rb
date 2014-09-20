module ForemanSalt
  module Concerns
    module HostsControllerExtensions
      extend ActiveSupport::Concern

      included do
        alias_method :find_by_name_salt, :find_by_name
        before_filter :find_by_name_salt, :only => [:saltrun]
        alias_method_chain :action_permission, :salt_run
        alias_method_chain :load_vars_for_ajax, :salt_modules
        alias_method_chain :process_hostgroup, :salt_modules
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
          @host = resource_base.find_by_name(params[:name])
          enc = {}
          env = @host.salt_environment.blank? ? 'base' : @host.salt_environment
          enc["classes"] = @host.salt_modules.any? ? @host.salt_modules.map(&:name) : []
          enc["parameters"] = @host.info["parameters"]
          enc["environment"] = env
          respond_to do |format|
            format.html { render :text => "<pre>#{ERB::Util.html_escape(enc.to_yaml)}</pre>" }
            format.yml  { render :text => enc.to_yaml }
          end
        rescue
          logger.warn "Failed to generate external nodes for #{@host} with #{$!}"
          render :text => _('Unable to generate output, Check log files\n'), :status => 412 and return
        end
      end

      def process_hostgroup_with_salt_modules
        @hostgroup = Hostgroup.find(params[:host][:hostgroup_id]) if params[:host][:hostgroup_id].to_i > 0
        return head(:not_found) unless @hostgroup

        @salt_modules           = @host.salt_modules if @host
        @inherited_salt_modules = @hostgroup.salt_modules
        process_hostgroup_without_salt_modules
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
        return unless @host
        @salt_modules           = @host.salt_modules
        @inherited_salt_modules = @host.hostgroup.salt_modules if @host.hostgroup
        load_vars_for_ajax_without_salt_modules
      end
    end
  end
end
