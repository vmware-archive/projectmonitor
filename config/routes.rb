CiMonitor::Application.routes.draw do

  root :to => 'default#show'
  match 'login' => 'sessions#new'

  resources :users, :only => [:new, :create]
  resource :openid, :only => [:new, :success] do
    member do
      get :success
    end
  end
  resource :session, :only => [:create, :destroy]
  resource :cimonitor, :controller => :ci_monitor, :only => [:show]
  resources :projects, :only => [:index, :new, :create, :edit, :update, :destroy]
  resources :messages, :only => [:index, :new, :create, :edit, :update, :destroy]

end
