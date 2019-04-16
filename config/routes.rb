Rails.application.routes.draw do
  scope :salt, :path => '/salt' do
    constraints(:id => /[\w\.-]+/) do
      match '/node/:id' => 'foreman_salt/minions#node', :via => :get
      match '/run/:id'  => 'foreman_salt/minions#run', :via => :get
    end

    resources :minions, :controller => 'foreman_salt/minions', :only => [] do
      collection do
        constraints(:id => /[^\/]+/) do
          put 'salt_environment_selected'
        end
      end
    end

    resources :salt_environments, :controller => 'foreman_salt/salt_environments' do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :salt_modules, :controller => 'foreman_salt/salt_modules' do
      collection do
        get 'import'
        get 'auto_complete_search'
        post 'apply_changes'
      end
    end

    scope :api, :path => '/api', :defaults => { :format => 'json' } do
      scope '(:apiv)', :defaults => { :apiv => 'v2' },
                       :apiv => /v1|v2/, :constraints => ApiConstraints.new(:version => 2) do
        match '/jobs/upload' => 'foreman_salt/api/v2/jobs#upload', :via => :post

        constraints(:smart_proxy_id => /[\w\.-]+/, :name => /[\w\.-]+/, :record => /[^\/]+/) do
          match '/salt_keys/:smart_proxy_id' => 'foreman_salt/api/v2/salt_keys#index', :via => :get
          match '/salt_keys/:smart_proxy_id/:name' => 'foreman_salt/api/v2/salt_keys#update', :via => :put
          match '/salt_keys/:smart_proxy_id/:name' => 'foreman_salt/api/v2/salt_keys#destroy', :via => :delete

          match '/salt_autosign/:smart_proxy_id' => 'foreman_salt/api/v2/salt_autosign#index', :via => :get
          match '/salt_autosign/:smart_proxy_id' => 'foreman_salt/api/v2/salt_autosign#create', :via => :post
          match '/salt_autosign/:smart_proxy_id/:record' => 'foreman_salt/api/v2/salt_autosign#destroy', :via => :delete

          match '/salt_states/import/:smart_proxy_id' => 'foreman_salt/api/v2/salt_states#import', :via => :post
        end

        constraints(:id => /[\w\.-]+/) do
          resources :salt_environments, :only => [:show, :index, :create, :destroy], :controller => 'foreman_salt/api/v2/salt_environments'
          resources :salt_minions, :only => [:show, :index, :update], :controller => 'foreman_salt/api/v2/salt_minions'
          resources :salt_states, :only => [:show, :index, :create, :destroy], :controller => 'foreman_salt/api/v2/salt_states'
        end
      end
    end
  end

  constraints(:smart_proxy_id => /[^\/]+/) do
    resources :smart_proxies, :except => [:show] do
      constraints(:id => /[^\/]+/) do
        resources :salt_autosign, :only => [:index, :destroy, :create, :new], :controller => 'foreman_salt/salt_autosign'
        resources :salt_keys, :only => [:index, :destroy], :controller => 'foreman_salt/salt_keys' do
          get :accept
          get :reject
        end
      end
    end
  end

  resources :hostgroups do
    collection do
      post 'salt_environment_selected'
    end
  end
end
