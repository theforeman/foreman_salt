Rails.application.routes.draw do

  scope :salt, :path => '/salt' do
    match "/node/:name" => 'hosts#salt_external_node', :constraints => { :name => /[^\.][\w\.-]+/ }

    resources :salt_environments, :controller => 'foreman_salt/salt_environments' do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :salt_modules, :controller => 'foreman_salt/salt_modules' do
      collection do
        get 'auto_complete_search'
      end
    end

    scope :api, :defaults => {:format => 'json'}, :constraints => ApiConstraints.new(:version => 2) do
      match 'api/v2/jobs/upload' => 'foreman_salt/api/v2/jobs#upload', :via => :post
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

  constraints(:id => /[^\/]+/) do
    resources :hosts do
      member do
        get :saltrun
      end
    end
  end
end
