class CreateSaltModules < ActiveRecord::Migration
  def self.up
    create_table :salt_modules do |t|
      t.string :name, :default => '', :null => false
      t.timestamps
    end

    create_table 'hosts_salt_modules', :id => false do |t|
      t.column :host_id, :integer
      t.column :salt_module_id, :integer
    end

    add_index :salt_modules, :name, :unique => true
  end

  def self.down
    drop_table :salt_modules
    drop_table :hosts_salt_modules
  end
end
