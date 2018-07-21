class ApplicationController < ActionController::Base
  include IPWhitelistedController
  protect_from_forgery with: :exception
end
