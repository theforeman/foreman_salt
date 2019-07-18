require 'deface'
require 'foreman_remote_execution'

module ForemanSalt
  class Engine < ::Rails::Engine
    engine_name 'foreman_salt'

    config.autoload_paths += Dir["#{config.root}/app/controllers/foreman_salt/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers"]
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

    initializer 'foreman_salt.register_gettext',
                :after => :load_config_initializers do
      locale_dir = File.join(File.expand_path('../..', __dir__), 'locale')
      locale_domain = 'foreman_salt'

      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end

    initializer 'foreman_salt.load_app_instance_data' do |app|
      ForemanSalt::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_salt.assets.precompile' do |app|
      app.config.assets.precompile += %w(foreman_salt/states.js)
    end

    initializer 'foreman_salt.assets.precompile' do |app|
      app.config.assets.precompile += %w[foreman_salt/Salt.png]
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

    initializer 'foreman_salt.register_plugin', :before => :finisher_hook do
      require 'foreman_salt/plugin'
    end

    config.to_prepare do
      require 'foreman_salt/extensions'

      RemoteExecutionProvider.register(:Salt, SaltProvider)
    end
  end

  # check whether foreman_remote_execution to integrate is available in the system
  def self.with_remote_execution?
    RemoteExecutionFeature rescue false
  end
end
