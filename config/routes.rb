Rails.application.routes.draw do

  scope :salt, :path => '/salt' do
    match "/node/:name" => 'hosts#salt_external_node', :constraints => { :name => /[^\.][\w\.-]+/ }

    resources :salt_modules, :controller => 'foreman_salt/salt_modules'
  end

  constraints(:id => /[^\/]+/) do
    resources :hosts do
      member do
        get :saltrun
      end
    end
  end
end
