class FixSaltSettingCategoryToDsl < ActiveRecord::Migration[6.0]
  def up
    Setting.where(category: 'Setting::Salt').update_all(category: 'Setting') if column_exists?(:settings, :category)
  end
end
