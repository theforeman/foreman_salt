require 'deface'

module ForemanSalt
  class Engine < ::Rails::Engine

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]
    config.autoload_paths += Dir["#{config.root}/app/services"]
    config.autoload_paths += Dir["#{config.root}/app/lib"]

    # Add any db migrations
    initializer "foreman_salt.load_app_instance_data" do |app|
      app.config.paths['db/migrate'] += ForemanSalt::Engine.paths['db/migrate'].existent
    end

    initializer 'foreman_salt.register_plugin', :after=> :finisher_hook do |app|
      Foreman::Plugin.register :foreman_salt do
        requires_foreman '>= 1.6'

        menu :top_menu, :salt_environments,
          :url_hash => {:controller => :'foreman_salt/salt_environments', :action => :index },
          :caption  => 'Environments',
          :parent   => :configure_menu,
          :after    => :common_parameters

        menu :top_menu, :salt_modules,
          :url_hash => {:controller => :'foreman_salt/salt_modules', :action => :index },
          :caption  => 'States',
          :parent   => :configure_menu,
          :after    => :common_parameters

        divider :top_menu, :parent => :configure_menu,
          :caption => "Salt",
          :after   => :common_parameters

        security_block :hosts do |map|
          permission :saltrun_hosts, {:hosts => [:saltrun]}, :resource_type => 'Host'
          permission :view_hosts, {:hosts => [:salt_external_node]}, :resource_type => 'Host'
        end

        security_block :salt_environments do |map|
          permission :create_salt_environments, {:'foreman_salt/salt_environments' => [:new, :create]}, :resource_type => "ForemanSalt::SaltEnvironment"
          permission :view_salt_environments, {:'foreman_salt/salt_environments' => [:index, :show, :auto_complete_search]}, :resource_type => "ForemanSalt::SaltEnvironment"
          permission :edit_salt_environments, {:'foreman_salt/salt_environments' => [:update, :edit]},:resource_type => "ForemanSalt::SaltEnvironment"
          permission :destroy_salt_environments, {:'foreman_salt/salt_environments' => [:destroy]}, :resource_type => "ForemanSalt::SaltEnvironment"
        end

        security_block :salt_modules do |map|
          permission :create_salt_modules, {:'foreman_salt/salt_modules' => [:new, :create]}, :resource_type => "ForemanSalt::SaltModule"
          permission :view_salt_modules, {:'foreman_salt/salt_modules' => [:index, :show, :auto_complete_search]}, :resource_type => "ForemanSalt::SaltModule"
          permission :edit_salt_modules, {:'foreman_salt/salt_modules' => [:update, :edit]},:resource_type => "ForemanSalt::SaltModule"
          permission :destroy_salt_modules, {:'foreman_salt/salt_modules' => [:destroy]}, :resource_type => "ForemanSalt::SaltModule"
        end

        security_block :salt_keys do |map|
          permission :view_smart_proxies_salt_keys, {:'foreman_salt/salt_keys' => [:index]}, :resource_type => "SmartProxy"
          permission :destroy_smart_proxies_salt_keys, {:'foreman_salt/salt_keys' => [:destroy]},:resource_type => "SmartProxy"
          permission :edit_smart_proxies_salt_keys, {:'foreman_salt/salt_keys' => [:accept, :reject]}, :resource_type => "SmartProxy"
        end

        security_block :salt_autosign do |map|
          permission :destroy_smart_proxies_salt_autosign, {:'foreman_salt/salt_autosign' => [:destroy]}, :resource_type => "SmartProxy"
          permission :create_smart_proxies_salt_autosign, {:'foreman_salt/salt_autosign' => [:new, :create]}, :resource_type => "SmartProxy"
          permission :view_smart_proxies_salt_autosign, {:'foreman_salt/salt_autosign' => [:index]}, :resource_type => "SmartProxy"
        end

        role "Salt admin", [:saltrun_hosts, :create_salt_modules, :view_salt_modules, :edit_salt_modules, :destroy_salt_modules,
                            :view_smart_proxies_salt_keys, :destroy_smart_proxies_salt_keys, :edit_smart_proxies_salt_keys,
                            :create_smart_proxies_salt_autosign, :view_smart_proxies_salt_autosign, :destroy_smart_proxies_salt_autosign,
                            :create_salt_environments, :view_salt_environments, :edit_salt_environments, :destroy_salt_environments]

      end
    end

    config.to_prepare do
      begin
        ::FactImporter.register_fact_importer(:foreman_salt, ForemanSalt::FactImporter)

        # Helper Extensions
        ::HostsHelper.send :include, ForemanSalt::HostsHelperExtensions
        ::SmartProxiesHelper.send :include, ForemanSalt::SmartProxiesHelperExtensions

        # Model Extensions
        ::Host::Managed.send :include, ForemanSalt::Concerns::HostManagedExtensions
        ::Host::Managed.send :include, ForemanSalt::Concerns::Orchestration::Salt
        ::Hostgroup.send :include, ForemanSalt::Concerns::HostgroupExtensions

        # Controller Extensions
        ::UnattendedController.send :include, ForemanSalt::Concerns::UnattendedControllerExtensions
        ::HostsController.send  :include, ForemanSalt::Concerns::HostsControllerExtensions
        ::HostsController.send  :include, ForemanSalt::Concerns::SmartProxyAuthExtensions
        ::HostgroupsController.send  :include, ForemanSalt::Concerns::HostgroupsControllerExtensions

        # API Extensions
        ::Api::V2::HostsController.send :include, ForemanSalt::Concerns::SmartProxyAuthExtensions
        ::Api::V2::ReportsController.send :include, ForemanSalt::Concerns::SmartProxyAuthExtensions
      rescue => e
        puts "ForemanSalt: skipping engine hook (#{e.to_s})"
      end
    end
  end
end
