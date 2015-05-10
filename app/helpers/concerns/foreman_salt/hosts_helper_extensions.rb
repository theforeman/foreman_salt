module ForemanSalt
  module HostsHelperExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :host_title_actions, :salt
      alias_method_chain :show_appropriate_host_buttons, :salt
      alias_method_chain :overview_fields, :salt
    end

    def show_appropriate_host_buttons_with_salt(host)
      (show_appropriate_host_buttons_without_salt(host) +
         [(link_to_if_authorized(_('Salt ENC'), { :controller => :'foreman_salt/minions', :action => :node, :id => host },
                                 :title => _('Salt external nodes YAML dump'), :class => 'btn btn-default') unless host.salt_master.blank?)]).flatten.compact
    end

    def host_title_actions_with_salt(host)
      title_actions(
        button_group(
          if host.try(:salt_proxy)
            link_to_if_authorized(_('Run Salt'), { :controller => :'foreman_salt/minions', :action => :run, :id => host },
                                  :title => _('Trigger a state.highstate run on a node'))
          end
        )
      )
      host_title_actions_without_salt(host)
    end

    def overview_fields_with_salt(host)
      fields = overview_fields_without_salt(host)

      fields.insert(5, [_("Salt Master"), (link_to(host.salt_proxy, hosts_path(:search => "saltmaster = #{host.salt_proxy}")) if host.salt_proxy)])
      fields.insert(6, [_("Salt Environment"), (link_to(host.salt_environment, hosts_path(:search => "salt_environment = #{host.salt_environment}")) if host.salt_environment)])

      fields
    end
  end
end
