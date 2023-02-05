Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'public#home'

  devise_for :users

  resources :items do
    collection do
      get :landing
    end
  end
end
