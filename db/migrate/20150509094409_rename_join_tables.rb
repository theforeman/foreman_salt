class RenameJoinTables < ActiveRecord::Migration[4.2]
  def up
    rename_table :hosts_salt_modules, :host_salt_modules
    rename_table :hostgroups_salt_modules, :hostgroup_salt_modules
  end

  def down
    rename_table :host_salt_modules, :hosts_salt_modules
    rename_table :hostgroup_salt_modules, :hostgroups_salt_modules
  end
end
