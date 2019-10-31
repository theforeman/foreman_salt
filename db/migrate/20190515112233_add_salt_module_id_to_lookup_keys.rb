# frozen_string_literal: true

# to keep track of when the modules were imported
class AddSaltModuleIdToLookupKeys < ActiveRecord::Migration[4.2]
  def up
    add_column :lookup_keys, :salt_module_id, :integer
    add_index :lookup_keys, :salt_module_id
  end

  def down
    remove_index :lookup_keys, :salt_module_id
    remove_column :lookup_keys, :salt_module_id
  end
end
