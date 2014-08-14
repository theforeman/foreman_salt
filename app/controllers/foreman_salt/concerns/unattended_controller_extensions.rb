module ForemanSalt
  module Concerns
    module UnattendedControllerExtensions
      extend ActiveSupport::Concern

      included do
        before_filter :handle_salt, :only => [:provision]
      end

      private

      def handle_salt
        return true if @spoof
        render(:text => _("Failed to set autosign for host. Terminating the build!"), :status => 500) unless @host.respond_to?(:handle_salt) && @host.handle_salt
      end
    end
  end
end
