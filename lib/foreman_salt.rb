require 'foreman_salt/engine'

begin
  require 'foreman-tasks'
rescue LoadError
  # Foreman Tasks isn't available
end

module ForemanSalt
end
