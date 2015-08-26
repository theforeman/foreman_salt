require 'deface'

module ForemanSalt
  class Engine < ::Rails::Engine
    engine_name 'foreman_salt'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]
    config.autoload_paths += Dir["#{config.root}/app/services"]
    config.autoload_paths += Dir["#{config.root}/app/lib"]

    initializer 'foreman_salt.require_dynflow', :before => 'foreman_tasks.initialize_dynflow' do
      ForemanTasks.dynflow.require!
    end

    initializer 'foreman_salt.load_default_settings', :before => :load_config_initializers do
      if (Setting.table_exists? rescue(false))
        require_dependency File.expand_path('../../../app/models/setting/salt.rb', __FILE__)
      end
    end

    initializer 'foreman_salt.load_app_instance_data' do |app|
      app.config.paths['db/migrate'] += ForemanSalt::Engine.paths['db/migrate'].existent
    end

    initializer 'foreman_salt.assets.precompile' do |app|
      app.config.assets.precompile += %w(foreman_salt/states.js)
    end

    initializer 'foreman_salt.configure_assets', :group => :assets do
      SETTINGS[:foreman_salt] = {
        :assets => {
          :precompile => ['foreman_salt/states.js']
        }
      }
    end

    initializer 'foreman_salt.apipie' do
      Apipie.configuration.checksum_path += ['/salt/api/']
    end

    initializer 'foreman_salt.register_plugin', :after => :finisher_hook do
      require 'foreman_salt/plugin'
    end

    config.to_prepare do
      require 'foreman_salt/extensions'
    end
  end
end
