CiMonitor::Application.routes.draw do

  root :to => 'default#show'
  match 'login' => 'sessions#new'
  match 'logout' => 'sessions#destroy'

  resources :users, :only => [:new, :create]
  resource :openid, :only => [:new, :success] do
    member do
      get :success
    end
  end
  resource :session, :only => [:create, :destroy]
  resource :dashboard, :only => [:show]
  resources :projects, :only => [:index, :new, :create, :edit, :update, :destroy]
  resources :aggregate_projects, :only => [:show, :new, :create, :edit, :update, :destroy]
  resources :messages, :only => [:index, :new, :create, :edit, :update, :destroy]
  resources :twitter_searches, :only => [:new, :create, :edit, :update, :destroy]
end
