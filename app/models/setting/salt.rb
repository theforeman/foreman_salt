class Setting
  class Salt < ::Setting
    def self.default_settings
      [
        set('salt_namespace_pillars', N_("Namespace Foreman pillars under 'foreman' key"), false),
      ]
    end
  end
end
