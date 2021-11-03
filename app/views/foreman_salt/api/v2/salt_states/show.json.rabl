object @salt_state

extends 'foreman_salt/api/v2/salt_states/base'

child :hostgroups do
  extends 'api/v2/hostgroups/base'
end

child :salt_environments do
  extends 'foreman_salt/api/v2/salt_environments/base'
end
