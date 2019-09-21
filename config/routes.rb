Rails.application.routes.draw do

  root 'static_pages#top'
  
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'session#create'
  delete '/logout', to: 'sessions#destroy'
  
  resources :users
end
