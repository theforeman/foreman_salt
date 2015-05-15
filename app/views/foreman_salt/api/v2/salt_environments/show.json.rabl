object @salt_environment

extends 'foreman_salt/api/v2/salt_environments/base'

child :salt_modules => :salt_states do
  extends 'foreman_salt/api/v2/salt_states/base'
end
