module ForemanSalt
  module Concerns
    module SmartProxyAuthExtensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :require_puppetmaster_or_login, :salt
        case self.controller_path
          when 'hosts'
            add_puppetmaster_filters [::HostsController::PUPPETMASTER_ACTIONS, :salt_external_node].flatten
        end
      end

      def require_puppetmaster_or_login_with_salt
        if auth_smart_proxy(::SmartProxy.with_features('Salt'), ::Setting[:require_ssl_puppetmasters])
          set_admin_user
          true
        else
          require_puppetmaster_or_login_without_salt
        end
      end
    end
  end
end
