Rails.application.routes.draw do

  root 'static_pages#top'
  
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  get 'users/:id/attendances/:id/edit_over_time', to: 'attendances#edit_over_time', as: :edit_over_time
  patch 'users/:id/attendances/:id/update_over_time', to: 'attendances#update_over_time', as: :update_over_time
  
  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
    end
    resources :attendances, only: :update
  end
end
