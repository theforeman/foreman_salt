module ForemanSalt
  module HostsHelperExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :host_title_actions, :salt_run
    end

    def host_title_actions_with_salt_run(host)
        title_actions(
          button_group(
            if host.try(:salt_proxy)
              link_to_if_authorized(_("Run Salt"), {:controller => :hosts, :action => :saltrun, :id => @host},
                                    :title => _("Trigger a state.highstate run on a node"))
            end
          )
        )
        host_title_actions_without_salt_run(host)
    end
  end
end
