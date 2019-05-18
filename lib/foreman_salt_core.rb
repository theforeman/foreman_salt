require 'foreman_tasks_core'
require 'foreman_remote_execution_core'

module ForemanSaltCore
  # extend ForemanTasksCore::SettingsLoader
  # register_settings(:salt)

  if ForemanTasksCore.dynflow_present?
    require 'foreman_salt_core/salt_runner'
    require 'foreman_salt_core/salt_task_launcher'

    if defined?(SmartProxyDynflowCore)
      SmartProxyDynflowCore::TaskLauncherRegistry.register('salt', SaltTaskLauncher)
    end
  end
end
