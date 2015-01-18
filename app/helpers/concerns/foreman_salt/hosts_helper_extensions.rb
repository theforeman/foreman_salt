module ForemanSalt
  module HostsHelperExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :host_title_actions, :salt_run
      alias_method_chain :show_appropriate_host_buttons, :salt
    end

    def show_appropriate_host_buttons_with_salt(host)
      (show_appropriate_host_buttons_without_salt(host) +
         [(link_to_if_authorized(_('Salt ENC'), { :controller => :'foreman_salt/minions', :action => :node, :id => host },
                                 :title => _('Salt external nodes YAML dump'), :class => 'btn btn-default') unless host.salt_master.blank?)]).flatten.compact
    end

    def host_title_actions_with_salt_run(host)
      title_actions(
        button_group(
          if host.try(:salt_proxy)
            link_to_if_authorized(_('Run Salt'), { :controller => :'foreman_salt/minions', :action => :run, :id => host },
                                  :title => _('Trigger a state.highstate run on a node'))
          end
        )
      )
      host_title_actions_without_salt_run(host)
    end
  end
end
