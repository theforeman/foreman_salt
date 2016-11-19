class AddIndexToJoinTables < ActiveRecord::Migration
  def change
    add_index :host_salt_modules, :host_id
    add_index :host_salt_modules, :salt_module_id
    add_index :hostgroup_salt_modules, :hostgroup_id
    add_index :hostgroup_salt_modules, :salt_module_id
  end
end
