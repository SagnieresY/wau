Rails.application.routes.draw do

  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    devise_for :users
    root to: 'pages#home'
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


    resources :investments do
      resources :milestones, only: [:new, :create, :edit, :update, :destroy]
    end

    resources :projects, only: [:show, :new, :create, :edit, :update]
    get '/no_foundation', to: 'pages#no_foundation', as: :no_foundation
    get '/archive', to: 'pages#archive', as: :archive
    get '/dashboard', to: 'pages#dashboard', as: :dashboard
    get '/landing', to: 'pages#landing', as: :landing
    post '/unlock_milestone', to: 'milestones#unlock', as: :unlock_milestone
    post '/rescind_milestone', to: 'milestones#rescind', as: :rescind_milestone
    post '/investment_unlocked_amount', to: 'investments#unlocked_amount', as: :investment_unlocked_amount

    match "/404", :to => "errors#not_found", :via => :all
    match "/500", :to => "errors#internal_server_error", :via => :all
  end
end
