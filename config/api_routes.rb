Rails.application.routes.draw do
  scope :salt, :path => '/salt' do
    namespace :api, defaults: { format: 'json' } do
      scope '(:apiv)', module: :v2, :defaults => { :apiv => 'v2' }, :apiv => /v1|v2/, :constraints => ApiConstraints.new(:version => 2, default: true) do
        match '/jobs/upload' => '/foreman_salt/api/v2/jobs#upload', :via => :post
        match '/salt_autosign_auth' => '/foreman_salt/api/v2/salt_autosign#auth', :via => :put

        constraints(:smart_proxy_id => /[\w\.-]+/, :name => /[\w\.-]+/, :record => /[^\/]+/) do
          match '/salt_keys/:smart_proxy_id' => '/foreman_salt/api/v2/salt_keys#index', :via => :get
          match '/salt_keys/:smart_proxy_id/:name' => '/foreman_salt/api/v2/salt_keys#update', :via => :put
          match '/salt_keys/:smart_proxy_id/:name' => '/foreman_salt/api/v2/salt_keys#destroy', :via => :delete

          match '/salt_autosign/:smart_proxy_id' => '/foreman_salt/api/v2/salt_autosign#index', :via => :get
          match '/salt_autosign/:smart_proxy_id' => '/foreman_salt/api/v2/salt_autosign#create', :via => :post
          match '/salt_autosign/:smart_proxy_id/:record' => '/foreman_salt/api/v2/salt_autosign#destroy', :via => :delete

          match '/salt_states/import/:smart_proxy_id' => '/foreman_salt/api/v2/salt_states#import', :via => :post
        end

        constraints(:id => /[\w\.-]+/) do
          resources :salt_environments, :only => [:show, :index, :create, :destroy], :controller => '/foreman_salt/api/v2/salt_environments'
          resources :salt_minions, :only => [:show, :index, :update], :controller => '/foreman_salt/api/v2/salt_minions'
          resources :salt_states, :only => [:show, :index, :create, :destroy], :controller => '/foreman_salt/api/v2/salt_states'
        end

        resources :salt_variables, :only => [:show, :index, :destroy, :update, :create], :controller => '/foreman_salt/api/v2/salt_variables'
      end
    end
  end
end
