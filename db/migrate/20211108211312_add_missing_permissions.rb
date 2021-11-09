class AddMissingPermissions < ActiveRecord::Migration[6.0]
  def up
    Permission.create!(:name => 'auth_smart_proxies_salt_autosign', :resource_type => 'SmartProxy')
  end

  def down
    Permission.where(:name => 'auth_smart_proxies_salt_autosign').destroy_all
  end
end
