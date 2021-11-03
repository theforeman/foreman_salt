class AddSaltModulesToHostgroups < ActiveRecord::Migration[4.2]
  def self.up
    create_table 'hostgroups_salt_modules', id: false do |t|
      t.column :hostgroup_id, :integer
      t.column :salt_module_id, :integer
    end
  end

  def self.down
    drop_table :hostgroups_salt_modules
  end
end
