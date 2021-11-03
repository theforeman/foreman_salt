class CreateSaltEnvironments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :salt_environments do |t|
      t.string :name, default: '', null: false
      t.timestamps null: true
    end

    add_column :hosts, :salt_environment_id, :integer
    add_column :hostgroups, :salt_environment_id, :integer

    add_index :salt_environments, :name, unique: true
  end

  def self.down
    remove_column :hosts, :salt_environment_id
    remove_column :hostgroups, :salt_environment_id
    drop_table :salt_environments
  end
end
