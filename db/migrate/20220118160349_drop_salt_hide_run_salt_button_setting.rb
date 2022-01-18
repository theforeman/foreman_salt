class DropSaltHideRunSaltButtonSetting < ActiveRecord::Migration[6.0]
  def up
    Setting.where(name: 'salt_hide_run_salt_button').delete_all
  end
end
