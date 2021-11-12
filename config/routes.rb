Rails.application.routes.draw do
  scope :salt, path: '/salt' do
    constraints(id: /[\w.-]+/) do
      get '/node/:id' => 'foreman_salt/minions#node'
      get '/run/:id'  => 'foreman_salt/minions#run'
    end

    resources :minions, controller: 'foreman_salt/minions', only: [] do
      collection do
        constraints(id: %r{[^/]+}) do
          put 'salt_environment_selected'
        end
      end
    end

    resources :salt_environments, controller: 'foreman_salt/salt_environments' do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :salt_modules, controller: 'foreman_salt/salt_modules' do
      collection do
        get 'import'
        get 'auto_complete_search'
        post 'apply_changes'
      end
    end

    resources :salt_variables, controller: 'foreman_salt/salt_variables', except: [:show] do
      resources :lookup_values, only: %i[index create update destroy]
      collection do
        get 'auto_complete_search'
      end
    end
  end

  constraints(id: %r{[^/]+}) do
    resources :hosts do
      collection do
        post 'select_multiple_salt_master'
        post 'update_multiple_salt_master'
        post 'select_multiple_salt_environment'
        post 'update_multiple_salt_environment'
      end
    end
  end

  constraints(smart_proxy_id: %r{[^/]+}) do
    resources :smart_proxies, except: [:show] do
      constraints(id: %r{[^/]+}) do
        resources :salt_autosign, only: %i[index destroy create new], controller: 'foreman_salt/salt_autosign'
        resources :salt_keys, only: %i[index destroy], controller: 'foreman_salt/salt_keys' do
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
