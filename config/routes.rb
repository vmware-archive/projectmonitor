CiMonitor::Application.routes.draw do
  match 'login' => 'sessions#new'
  match 'logout' => 'sessions#destroy'
  match 'builds.rss' => "dashboards#builds", format: :rss
  match 'projects/validate_tracker_project'
  match 'projects/update_projects'
  match 'version' => 'versions#show'

  resource :configuration, only: [:show, :create], controller: "configuration"
  resources :users, :only => [:new, :create]
  resource :openid, :only => [:new, :success] do
    member do
      get :success
    end
  end
  resource :session, :only => [:create, :destroy]
  resources :projects, only: [:index, :new, :create, :edit, :update, :destroy] do
    resource :status, only: :create, controller: "status"
    member do
      get :status
    end
  end
  resources :aggregate_projects, only: [:show, :new, :create, :edit, :update, :destroy] do
    member do
      get :status
    end
  end
  resources :messages, only: [:index, :new, :create, :edit, :update, :destroy] do
    get :load_message
  end
  resources :twitter_searches, only: [:new, :create, :edit, :update, :destroy] do
    get :load_tweet
  end

  root :to => 'dashboards#index'
end
