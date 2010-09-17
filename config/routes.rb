ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'default', :action => 'show'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.resources :users, :only => [:new, :create]
  map.resource :session, :only => [:create, :destroy]
  map.resource :cimonitor, :controller => :ci_monitor, :only => [:show]
  map.resources :projects, :only => [:index, :new, :create, :edit, :update, :destroy]
  map.resources :messages, :only => [:index, :new, :create, :edit, :update, :destroy]

end
