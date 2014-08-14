Rails.application.routes.draw do

  constraints(:id => /[^\/]+/) do
    resources :hosts do
      member do
        get 'saltrun'
      end
    end
  end

end
