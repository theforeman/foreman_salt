class AddMissingPermissions < ActiveRecord::Migration[6.0]
  def up
    Permission.where(name: 'auth_smart_proxies_salt_autosign', resource_type: 'SmartProxy').first_or_create
  end

  def down
    Permission.where(name: 'auth_smart_proxies_salt_autosign').destroy_all
  end
end
