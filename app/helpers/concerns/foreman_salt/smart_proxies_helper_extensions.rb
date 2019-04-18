module ForemanSalt
  module SmartProxiesHelperExtensions
    extend ActiveSupport::Concern

    module Overrides
      def feature_actions(proxy, authorizer)
        actions = super

        if proxy.has_feature?('Salt')
          actions << display_link_if_authorized(_('Salt Keys'), :controller => 'foreman_salt/salt_keys', :action => 'index', :smart_proxy_id => proxy)
          actions << display_link_if_authorized(_('Salt Autosign'), :controller => 'foreman_salt/salt_autosign', :action => 'index', :smart_proxy_id => proxy)
        end

        actions
      end
    end

    included do
      prepend Overrides
    end
  end
end
