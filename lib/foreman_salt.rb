require 'foreman_salt/engine'

begin
  require 'foreman-tasks'
rescue LoadError
  puts 'ForemanTasks is not available, async tasks disabled.'
end

module ForemanSalt
end
