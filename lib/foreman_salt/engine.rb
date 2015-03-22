require 'deface'

module ForemanSalt
  class Engine < ::Rails::Engine
    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]
    config.autoload_paths += Dir["#{config.root}/app/services"]
    config.autoload_paths += Dir["#{config.root}/app/lib"]

    initializer 'foreman_salt.require_dynflow', :before => 'foreman_tasks.initialize_dynflow' do |_app|
      ForemanTasks.dynflow.require!
    end

    initializer 'foreman_salt.load_default_settings', :before => :load_config_initializers do
      require_dependency File.expand_path('../../../app/models/setting/salt.rb', __FILE__) if (Setting.table_exists? rescue(false))
    end

    initializer 'foreman_salt.load_app_instance_data' do |app|
      app.config.paths['db/migrate'] += ForemanSalt::Engine.paths['db/migrate'].existent
    end

    initializer 'foreman_salt.apipie' do
      Apipie.configuration.checksum_path += ['/salt/api/']
    end

    initializer 'foreman_salt.register_plugin', :after => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_salt do
        requires_foreman '>= 1.9'

        apipie_documented_controllers ["#{ForemanSalt::Engine.root}/app/controllers/foreman_salt/api/v2/*.rb"]

        ## Menus
        menu :top_menu, :salt_environments,
             :url_hash => { :controller => :'foreman_salt/salt_environments', :action => :index },
             :caption  => 'Environments',
             :parent   => :configure_menu,
             :after    => :common_parameters

        menu :top_menu, :salt_modules,
             :url_hash => { :controller => :'foreman_salt/salt_modules', :action => :index },
             :caption  => 'States',
             :parent   => :configure_menu,
             :after    => :common_parameters

        divider :top_menu, :parent => :configure_menu,
                           :caption => 'Salt',
                           :after   => :common_parameters

        # Permissions
        security_block :foreman_salt do |_map|
          permission :destroy_smart_proxies_salt_autosign,
                     { :'foreman_salt/salt_autosign' => [:destroy],
                       :'foreman_salt/api/v2/salt_autosign' => [:destroy] },
                     :resource_type => 'SmartProxy'

          permission :create_smart_proxies_salt_autosign,
                     { :'foreman_salt/salt_autosign' => [:new, :create],
                       :'foreman_salt/api/v2/salt_autosign' => [:create] },
                     :resource_type => 'SmartProxy'

          permission :view_smart_proxies_salt_autosign,
                     { :'foreman_salt/salt_autosign' => [:index],
                       :'foreman_salt/api/v2/salt_autosign' => [:index] },
                     :resource_type => 'SmartProxy'

          permission :create_salt_environments,
                     { :'foreman_salt/salt_environments' => [:new, :create],
                       :'foreman_salt/api/v2/salt_environments' => [:create] },
                     :resource_type => 'ForemanSalt::SaltEnvironment'

          permission :view_salt_environments,
                     { :'foreman_salt/salt_environments' => [:index, :show, :auto_complete_search],
                       :'foreman_salt/api/v2/salt_environments' => [:index, :show] },
                     :resource_type => 'ForemanSalt::SaltEnvironment'

          permission :edit_salt_environments,
                     { :'foreman_salt/salt_environments' => [:update, :edit] },
                     :resource_type => 'ForemanSalt::SaltEnvironment'

          permission :destroy_salt_environments,
                     { :'foreman_salt/salt_environments' => [:destroy],
                       :'foreman_salt/api/v2/salt_environments' => [:destroy] },
                     :resource_type => 'ForemanSalt::SaltEnvironment'

          permission :create_reports,
                     { :'foreman_salt/api/v2/jobs' => [:upload] },
                     :resource_type => 'Report'

          permission :saltrun_hosts,
                     { :'foreman_salt/minions' => [:run] },
                     :resource_type => 'Host'

          permission :edit_hosts,
                     { :'foreman_salt/api/v2/salt_minions' => [:update] },
                     :resource_type => 'Host'

          permission :view_hosts,
                     { :'foreman_salt/minions' => [:node],
                       :'foreman_salt/api/v2/salt_minions' => [:index, :show] },
                     :resource_type => 'Host'

          permission :view_smart_proxies_salt_keys,
                     { :'foreman_salt/salt_keys' => [:index],
                       :'foreman_salt/api/v2/salt_keys' => [:index] },
                     :resource_type => 'SmartProxy'

          permission :destroy_smart_proxies_salt_keys,
                     { :'foreman_salt/salt_keys' => [:destroy],
                       :'foreman_salt/api/v2/salt_keys' => [:destroy] },
                     :resource_type => 'SmartProxy'

          permission :edit_smart_proxies_salt_keys,
                     { :'foreman_salt/salt_keys' => [:accept, :reject],
                       :'foreman_salt/api/v2/salt_keys' => [:update] },
                     :resource_type => 'SmartProxy'

          permission :create_salt_modules,
                     { :'foreman_salt/salt_modules' => [:new, :create],
                       :'foreman_salt/api/v2/salt_states' => [:create] },
                     :resource_type => 'ForemanSalt::SaltModule'

          permission :view_salt_modules,
                     { :'foreman_salt/salt_modules' => [:index, :show, :auto_complete_search],
                       :'foreman_salt/api/v2/salt_states' => [:index, :show] },
                     :resource_type => 'ForemanSalt::SaltModule'

          permission :edit_salt_modules,
                     { :'foreman_salt/salt_modules' => [:update, :edit] },
                     :resource_type => 'ForemanSalt::SaltModule'

          permission :destroy_salt_modules,
                     { :'foreman_salt/salt_modules' => [:destroy],
                       :'foreman_salt/api/v2/salt_states' => [:destroy] },
                     :resource_type => 'ForemanSalt::SaltModule'
        end

        ## Roles
        role 'Salt admin', [:saltrun_hosts, :create_salt_modules, :view_salt_modules, :edit_salt_modules, :destroy_salt_modules,
                            :view_smart_proxies_salt_keys, :destroy_smart_proxies_salt_keys, :edit_smart_proxies_salt_keys,
                            :create_smart_proxies_salt_autosign, :view_smart_proxies_salt_autosign, :destroy_smart_proxies_salt_autosign,
                            :create_salt_environments, :view_salt_environments, :edit_salt_environments, :destroy_salt_environments]
      end
    end

    config.to_prepare do
      begin
        ::FactImporter.register_fact_importer(:foreman_salt, ForemanSalt::FactImporter)
        ::FactParser.register_fact_importer(:foreman_salt, ForemanSalt::FactParser)

        # Helper Extensions
        ::HostsHelper.send :include, ForemanSalt::HostsHelperExtensions
        ::SmartProxiesHelper.send :include, ForemanSalt::SmartProxiesHelperExtensions

        # Model Extensions
        ::Host::Managed.send :include, ForemanSalt::Concerns::HostManagedExtensions
        ::Host::Managed.send :include, ForemanSalt::Concerns::Orchestration::Salt
        ::Hostgroup.send :include, ForemanSalt::Concerns::HostgroupExtensions

        # Controller Extensions
        ::UnattendedController.send :include, ForemanSalt::Concerns::UnattendedControllerExtensions
        ::HostsController.send :include, ForemanSalt::Concerns::HostsControllerExtensions
        ::HostgroupsController.send :include, ForemanSalt::Concerns::HostgroupsControllerExtensions
      rescue => e
        puts "ForemanSalt: skipping engine hook (#{e})"
      end
    end
  end
end
