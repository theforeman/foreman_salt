module ForemanSalt
  module SmartProxiesHelperExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :proxy_actions, :salt_proxy
    end

    def proxy_actions_with_salt_proxy(proxy, authorizer)
      salt = proxy.features.detect { |feature| feature.name == 'Salt' }
      [
        if salt
          display_link_if_authorized(_('Salt Keys'), {:controller => 'foreman_salt/salt_keys', :action => 'index', :smart_proxy_id => proxy})
        end,

        if salt
          display_link_if_authorized(_('Salt Autosign'), {:controller => 'foreman_salt/salt_autosign', :action => 'index', :smart_proxy_id => proxy})
        end
      ] + proxy_actions_without_salt_proxy(proxy, authorizer)
    end
  end
end
