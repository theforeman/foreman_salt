class AddSaltAutosignToHost < ActiveRecord::Migration[4.2]
  def change
    add_column :hosts, :salt_autosign_key, :string, limit: 255, null: true
    add_column :hosts, :salt_status, :string, limit: 255, null: true
  end
end
