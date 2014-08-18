require 'deface'

module ForemanSalt
  class Engine < ::Rails::Engine

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]
    config.autoload_paths += Dir["#{config.root}/app/lib"]

    # Add any db migrations
    initializer "foreman_salt.load_app_instance_data" do |app|
      app.config.paths['db/migrate'] += ForemanSalt::Engine.paths['db/migrate'].existent
    end

    initializer 'foreman_salt.register_plugin', :after=> :finisher_hook do |app|
      Foreman::Plugin.register :foreman_salt do
        requires_foreman '>= 1.5'

        menu :top_menu, :salt,
          :url_hash => {:controller => :'foreman_salt/salt_modules', :action => :index },
          :caption  => 'Modules',
          :parent   => :configure_menu,
          :after    => :common_parameters

        divider :top_menu, :parent => :configure_menu,
          :caption => "Salt",
          :after   => :common_parameters

        security_block :hosts do |map|
          permission :saltrun_hosts, {:hosts => [:saltrun]}, :resource_type => 'Host'
        end

        security_block :salt_modules do |map|
          permission :create_salt_modules,  {:'foreman_salt/salt_modules' => [:new, :create]}, :resource_type => "ForemanSalt::SaltModule"
          permission :view_salt_modules,    {:'foreman_salt/salt_modules' => [:index, :show]}, :resource_type => "ForemanSalt::SaltModule"
          permission :edit_salt_modules,    {:'foreman_salt/salt_modules' => [:update]},       :resource_type => "ForemanSalt::SaltModule"
          permission :destroy_salt_modules, {:'foreman_salt/salt_modules' => [:destroy]},      :resource_type => "ForemanSalt::SaltModule"
        end

        role "Salt admin", [:saltrun_hosts, :create_salt_modules, :view_salt_modules, :edit_salt_modules, :destroy_salt_modules]

      end
    end

    config.to_prepare do
      begin
        ::FactImporter.register_fact_importer(:foreman_salt, ForemanSalt::FactImporter)

        # Helper Extensions
        HostsHelper.send(:include, ForemanSalt::HostsHelperExtensions)

        # Model Extensions
        ::Host::Managed.send :include, ForemanSalt::Concerns::HostManagedExtensions
        ::Host::Managed.send :include, ForemanSalt::Orchestration::Salt
        ::Hostgroup.send :include, ForemanSalt::Concerns::HostgroupExtensions

        # Controller Extensions
        ::UnattendedController.send :include, ForemanSalt::Concerns::UnattendedControllerExtensions
        ::HostsController.send  :include, ForemanSalt::Concerns::HostsControllerExtensions

        # API Extensions
        ::Api::V2::HostsController.send :include, ForemanSalt::Concerns::SmartProxyAuthExtensions
        ::Api::V2::ReportsController.send :include, ForemanSalt::Concerns::SmartProxyAuthExtensions
      rescue => e
        puts "ForemanSalt: skipping engine hook (#{e.to_s})"
      end
    end
  end
end
