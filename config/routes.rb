Rails.application.routes.draw do
  root 'public#home'

  devise_for :users

  resources :items do
    member do
      put :answer
      put :reset_to_zero
      put :shift
    end

    collection do
      get :next
      get :search
      get :pending
      get :landing
      get :no_next
    end
  end
end
