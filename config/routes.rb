require "sidekiq/web"

Rails.application.routes.draw do
  # Defines the root path route ("/")
  root 'admin/api_users#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Sidekiq
  mount Sidekiq::Web => "/sidekiq" # access it at http://localhost:3000/sidekiq

  # Devise gem
  devise_for :users,
           controllers: {
             sessions: "users/sessions"
           }

  namespace :api do
    namespace :v1 do
      resources :items, only: [:index]
    end
  end

  namespace :admin do
    resources :api_users
    resources :admin_users
    resources :items do
      resources :item_prices
      resources :item_upcs
    end
    resources :import_items, only: [:index, :create]
    resources :import_item_prices, only: [:index, :create]
    resources :import_item_upcs, only: [:index, :create]
    resources :import_batches, only: [] do
      member do
        get :download_failed
      end
    end
  end

  get 'info' => 'api_users#info'
end
