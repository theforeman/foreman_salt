object @salt_hostgroup

attributes :id, :name, :salt_master, :salt_environment

child salt_modules: :salt_states do
  extends 'foreman_salt/api/v2/salt_states/base'
end
