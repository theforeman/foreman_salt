Rails.application.routes.draw do

  match 'new_action', :to => 'foreman_salt/hosts#new_action'

end
