module ForemanSalt
  module SmartProxiesHelperExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :proxy_actions, :salt_proxy
    end

    def proxy_actions_with_salt_proxy(proxy, authorizer)
      actions = proxy_actions_without_salt_proxy(proxy, authorizer)

      if proxy.has_feature?('Salt')
        actions << display_link_if_authorized(_('Salt Keys'), :controller => 'foreman_salt/salt_keys', :action => 'index', :smart_proxy_id => proxy)
        actions << display_link_if_authorized(_('Salt Autosign'), :controller => 'foreman_salt/salt_autosign', :action => 'index', :smart_proxy_id => proxy)
      end

      actions
    end
  end
end
