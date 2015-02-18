Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  root 'cats#index'
  get '/login' => 'cats#login'
  post '/authenticate' => 'cats#authenticate'
  resources :cats
end
