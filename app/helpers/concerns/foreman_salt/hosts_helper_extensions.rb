module ForemanSalt
  module HostsHelperExtensions
    extend ActiveSupport::Concern

    module Overrides
      def show_appropriate_host_buttons(host)
        (super(host) +
         [(link_to_if_authorized(_('Salt ENC'), { :controller => :'foreman_salt/minions', :action => :node, :id => host },
                                 :title => _('Salt external nodes YAML dump'), :class => 'btn btn-default') unless host.salt_master.blank?)]).flatten.compact
      end

      def host_title_actions(host)
        unless Setting[:salt_hide_run_salt_button]
          title_actions(
            button_group(
              if host.try(:salt_proxy)
                link_to_if_authorized(_('Run Salt'), { :controller => :'foreman_salt/minions', :action => :run, :id => host },
                                      :title => _('Trigger a state.highstate run on a node'), :class => 'btn btn-primary')
            end
            )
          )
        end
        super(host)
      end

      def multiple_actions
        actions = super
        if authorized_for(:controller => :hosts, :action => :edit)
          actions << [_('Change Salt Master'), select_multiple_salt_master_hosts_path] if SmartProxy.unscoped.authorized.with_features("Salt")
          actions << [_('Change Salt Environment'), select_multiple_salt_environment_hosts_path] if SmartProxy.unscoped.authorized.with_features("Salt")
        end
        actions
      end

      def overview_fields(host)
        fields = super(host)

        fields.insert(5, [_('Salt Master'), (link_to(host.salt_proxy, hosts_path(:search => "saltmaster = #{host.salt_proxy}")) if host.salt_proxy)])
        fields.insert(6, [_('Salt Environment'), (link_to(host.salt_environment, hosts_path(:search => "salt_environment = #{host.salt_environment}")) if host.salt_environment)])

        fields
      end
    end

    included do
      prepend Overrides
    end
  end
end
