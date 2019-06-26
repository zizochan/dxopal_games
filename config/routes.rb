Rails.application.routes.draw do
  root :to => 'game#index'

  get 'game/index'

  get 'game/tamayoke'
  get 'game/tamayoke_source'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
