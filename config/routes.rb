ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.resource :login, :controller => "sessions"
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.resources :users

  map.resource :session

  map.home_page '', :controller => "default", :action => "show"

  map.resource :cimonitor, :controller => :ci_monitor
  map.resources :projects
  map.resources :messages

  map.root :controller => 'default', :action => 'show'
end
