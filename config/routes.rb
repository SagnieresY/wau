Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


  resources :investments do
    resources :milestones, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :projects, only: [:show, :new, :create, :edit, :update]
  get '/no_foundation', to: 'pages#no_foundation', as: :no_foundation
  get '/dashboard', to: 'pages#dashboard', as: :dashboard
  post '/unlock_milestone', to: 'milestones#unlock', as: :unlock_milestone
end
