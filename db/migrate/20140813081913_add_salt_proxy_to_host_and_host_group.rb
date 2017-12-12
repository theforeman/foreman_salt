class AddSaltProxyToHostAndHostGroup < ActiveRecord::Migration[4.2]
  def self.up
    add_column :hosts, :salt_proxy_id, :integer
    add_column :hostgroups, :salt_proxy_id, :integer
  end

  def self.down
    remove_column :hosts, :salt_proxy_id
    remove_column :hostgroups, :salt_proxy_id
  end
end
