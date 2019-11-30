Rails.application.routes.draw do

  root 'static_pages#top'
  
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  get 'users/:id/attendances/:id/edit_overtime_work', to: 'attendances#edit_overtime_work', as: :edit_overtime
  patch 'users/:id/attendances/:id/update_overtime_work', to: 'attendances#update_overtime_work', as: :update_overtime
  
  get 'users/:user_id/attendances/:id/edit_overtime_work_info', to: 'attendances#edit_overtime_work_info', as: :edit_overtime_info
  patch 'users/:user_id/attendances/:id/update_overtime_work_info', to: 'attendances#update_overtime_work_info', as: :update_overtime_info
  
  patch 'users/:id/attendances/:id/update_one_month_info', to: 'attendances#update_one_month_info', as: :update_month_info
  
  get 'users/:user_id/attendances/:id/edit_month_work_info', to: 'attendances#edit_month_work_info', as: :edit_month_work_info
  patch 'users/:user_id/attendances/:id/update_month_work_info', to: 'attendances#update_month_work_info', as: :update_month_work_info
  
  get 'users/:user_id/attendances/:id/edit_worked_info', to: 'attendances#edit_worked_info', as: :edit_worked_info
  patch 'users/:user_id/attendances/:id/update_worked_info', to: 'attendances#update_worked_info', as: :update_worked_info
  
  get 'users/:id/workig_employee', to: 'users#working_employee', as: :working_employee
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
