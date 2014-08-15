module ForemanSalt
  module Concerns
    module SmartProxyAuthExtensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :require_puppetmaster_or_login, :salt_proxy
      end

      def require_puppetmaster_or_login_with_salt_proxy
        if auth_smart_proxy(::SmartProxy.with_features("Salt"), ::Setting[:require_ssl_puppetmasters])
          set_admin_user
          return true
        else
          require_puppetmaster_or_login_without_salt_proxy
        end
      end
    end
  end
end
