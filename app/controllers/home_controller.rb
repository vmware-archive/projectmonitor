class HomeController < ApplicationController

  respond_to :json, :only => [:index]

  def index
  end
end
