ProjectMonitor::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks", :sessions => "sessions" }
  match 'builds.rss' => "home#builds", format: :rss
  match 'projects/validate_tracker_project'
  match 'projects/validate_build_info'
  match 'version' => 'versions#show'
  match 'github_status' => 'home#github_status', format: :json
  match 'heroku_status' => 'home#heroku_status', format: :json
  match 'rubygems_status' => 'home#rubygems_status', format: :json

  resource :configuration, only: [:show, :create, :edit], controller: "configuration"
  resources :users, :only => [:new, :create]
  resources :projects do
    resources :payload_log_entries, only: :index
    resource :status, only: :create, controller: "status"
    member do
      get :status
    end
  end
  resources :aggregate_projects do
    member do
      get :status
    end
    resources :projects, only: [:index]
  end
  resources :messages, only: [:index, :new, :create, :edit, :update, :destroy] do
    get :load_message
  end

  match 'styleguide' => 'home#styleguide'
  root :to => 'home#index'
end
