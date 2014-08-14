module ForemanSalt
  module Concerns
    module HostsControllerExtensions
      extend ActiveSupport::Concern

      included do
        alias_method :find_by_name_saltrun, :find_by_name
        before_filter :find_by_name_saltrun, :only => %w[saltrun]
        alias_method_chain :action_permission, :salt_run
      end

      def saltrun
        if @host.saltrun!
          notice _("Successfully executed, check log files for more details")
        else
          error @host.errors[:base].to_sentence
        end
        redirect_to host_path(@host)
      end

      private

      def action_permission_with_salt_run
        case params[:action]
          when 'saltrun'
            :saltrun
          else
            action_permission_without_salt_run
        end
      end
    end
  end
end
