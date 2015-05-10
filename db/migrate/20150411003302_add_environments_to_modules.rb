class AddEnvironmentsToModules < ActiveRecord::Migration
  def up
    create_table 'salt_module_environments' do |t|
      t.references :salt_module
      t.references :salt_environment
    end

    environments = ForemanSalt::SaltEnvironment.all
    ForemanSalt::SaltModule.all.each do |state|
      state.salt_environments << environments
    end
  end

  def down
    drop_table :salt_module_environments
  end
end
