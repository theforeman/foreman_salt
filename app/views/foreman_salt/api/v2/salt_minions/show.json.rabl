object @salt_minion

extends "foreman_salt/api/v2/salt_minions/main"

child :salt_modules => :salt_states do
  extends "foreman_salt/api/v2/salt_states/base"
end

