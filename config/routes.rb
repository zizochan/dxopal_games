Rails.application.routes.draw do
  root :to => 'games#index'

  resources :games, only: [:index, :show] do
    member do
      get :source
    end
  end
end
