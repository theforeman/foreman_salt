class Setting::Salt < Setting
  def self.default_settings
    [
      set('salt_namespace_pillars', N_("Namespace Foreman pillars under 'foreman' key"), false),
      set('salt_hide_run_salt_button', N_("Hide the Run Salt state.highstate button on the host details page"), false)
    ]
  end

  def self.load_defaults
    super
    Setting['salt_hide_run_salt_button'] = true if ForemanSalt.with_remote_execution?
  end
end
