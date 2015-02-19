class Setting::Salt < Setting
  def self.load_defaults
    return unless super

    transaction do
      [
        set('salt_namespace_pillars', N_("Namespace Foreman pillars under 'foreman' key"), false)
      ].each { |s| self.create! s.update(:category => 'Setting::Salt') }
    end
    true
  end
end
