module ForemanSalt
  module Concerns
    module HostsControllerExtensions
      extend ActiveSupport::Concern
      MULTIPLE_EDIT_ACTIONS = %w(select_multiple_salt_environment update_multiple_salt_environment
                                 select_multiple_salt_master update_multiple_salt_master)

      module Overrides
        def process_hostgroup
          @hostgroup = Hostgroup.find(params[:host][:hostgroup_id]) if params[:host][:hostgroup_id].to_i.positive?
          return head(:not_found) unless @hostgroup

          @salt_modules           = @host.salt_modules if @host
          @salt_environment       = @host.salt_environment if @host
          @inherited_salt_modules = @hostgroup.all_salt_modules
          super
        end

        private

        def load_vars_for_ajax
          return unless @host

          @obj                    = @host
          @salt_environment       = @host.salt_environment if @host
          @selected               = @host.salt_modules
          @salt_modules           = @host.salt_environment ? @salt_environment.salt_modules : []
          @inherited_salt_modules = @host.hostgroup.all_salt_modules if @host.hostgroup
          super
        end
      end

      included do
        prepend Overrides
        define_action_permission MULTIPLE_EDIT_ACTIONS, :edit
      end

      def select_multiple_salt_master
        find_multiple
      end

      def update_multiple_salt_master
        find_multiple
        update_multiple_proxy(_('Salt Master'), :salt_proxy=)
      end

      def select_multiple_salt_environment
        find_multiple
      end

      def update_multiple_salt_environment
        # simple validations
        if params[:salt_environment].nil? || (id = params[:salt_environment][:id]).nil?
          error _('No salt environment selected!')
          redirect_to(select_multiple_salt_environment_hosts_path)
          return
        end

        find_multiple
        ev = ForemanSalt::SaltEnvironment.find_by_id(id)

        # update the hosts
        @hosts.each do |host|
          host.salt_environment = ev
          host.save(:validate => false)
          ProxyAPI::Salt.new(:url => salt_proxy.url).refresh_pillar host.name
        end

        success _('Updated hosts: changed salt environment')
        redirect_back_or_to hosts_path
      end
    end
  end
end
