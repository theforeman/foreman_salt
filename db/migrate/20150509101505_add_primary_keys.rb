class AddPrimaryKeys < ActiveRecord::Migration[4.2]
  def change
    add_column :host_salt_modules, :id, :primary_key
    add_column :hostgroup_salt_modules, :id, :primary_key
  end
end
