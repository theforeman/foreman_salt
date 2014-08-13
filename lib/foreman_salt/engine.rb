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
      end
    end

    config.to_prepare do
      begin
        # Model Extensions
        ::Host::Managed.send :include, ForemanSalt::Concerns::HostManagedExtensions
        ::Host::Managed.send :include, ForemanSalt::Orchestration::Salt
        ::Hostgroup.send     :include, ForemanSalt::Concerns::HostgroupExtensions

        # Controller Extensions
        ::UnattendedController.send :include, ForemanSalt::Concerns::UnattendedControllerExtensions
      rescue => e
        puts "ForemanSalt: skipping engine hook (#{e.to_s})"
      end
    end
  end
end
